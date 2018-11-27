# Copyright 2018 Google Inc
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'linked-list'
require 'set'
require 'strscan'

require_relative 'hrx/file'
require_relative 'hrx/directory'
require_relative 'hrx/error'
require_relative 'hrx/linked_list'
require_relative 'hrx/ordered_node'
require_relative 'hrx/parse_error'

# An HRX archive.
class HRX
  class << self
    # Parses an HRX file's text.
    #
    # If `file` is passed, it's used as the file name for error reporting.
    def parse(text, file: nil)
      text = text.encode("UTF-8")
      return new if text.empty?

      scanner = StringScanner.new(text)
      unless boundary = scanner.scan(/<=+>/)
        HRX::Util.parse_error(scanner, "Expected boundary", file: file)
      end
      boundary_length = boundary.length - 2
      hrx = HRX.new(boundary_length: boundary_length)
      boundary_regexp = /^<={#{boundary_length}}>/m

      loop do
        if scanner.scan(/\n/)
          if comment_plus_boundary = scanner.scan_until(boundary_regexp)
            comment = comment_plus_boundary[0...-boundary_length - 3]
          else
            hrx.last_comment = scanner.rest
            return hrx
          end
        end

        unless scanner.scan(/ /)
          HRX::Util.parse_error(scanner, "Expected space", file: file)
        end

        before_path = scanner.pos
        path = HRX::Util.scan_path(scanner, assert_done: false, file: file)
        unless scanner.scan(/\n/)
          HRX::Util.parse_error(scanner, "Expected newline", file: file)
        end

        begin
          if path.end_with?("/")
            hrx << HRX::Directory._new_without_checks(path, comment)
            return hrx if scanner.eos?
            next if scanner.scan(boundary_regexp)
            HRX::Util.parse_error(scanner, "Expected boundary", file: file)
          end

          if content_plus_boundary = scanner.scan_until(boundary_regexp)
            content = content_plus_boundary[0...-boundary_length - 3]
            hrx << HRX::File._new_without_checks(path, content, comment)
          else
            hrx << HRX::File._new_without_checks(path, scanner.rest, comment)
            return hrx
          end
        rescue HRX::ParseError => e
          raise e
        rescue HRX::Error => e
          scanner.pos = before_path
          HRX::Util.parse_error(scanner, e.message, file: file)
        end
      end
    end
  end

  # The last comment in the document, or `nil` if it has no final comment.
  #
  # HRX comments are always encoded as UTF-8.
  attr_reader :last_comment

  # Creates a new, empty archive.
  #
  # The `boundary_length` is the number of `=` signs to include in the boundary
  # when #to_hrx is called, unless a file already contains that boundary.
  def initialize(boundary_length: 3)
    if boundary_length && boundary_length < 1
      raise ArgumentError.new("boundary_length must be 1 or greater")
    end

    @boundary_length = boundary_length
    @entries = HRX::List.new
    @entries_by_path = {}
  end

  # A frozen array of the HRX::File and/or HRX::Directory objects that this
  # archive contains.
  #
  # Note that a new array is created every time this method is called, so try to
  # avoid calling this many times in a tight loop.
  def entries
    @entries.to_a.freeze
  end

  # Returns the HRX::File or HRX::Directory at the given `path` in this archive,
  # or `nil` if there's no entry at that path.
  #
  # This doesn't verify that `path` is well-formed, but instead just returns
  # `nil`.
  #
  # If `path` ends with `"/"`, returns `nil` if the entry at the given path is a
  # file rather than a directory.
  def [](path)
    _find_node(path)&.data
  end

  # Returns the contents of the file at `path` in the archive.
  #
  # Throws an HRX::Error if there is no file at `path`, or if `path` is invalid
  # (including if it ends with `/`).
  def read(path)
    raise HRX::Error.new("There is no file at \"#{path}\"") unless node = _find_node(path)
    raise HRX::Error.new("\"#{node.data.path}\" is a directory") unless node.data.is_a?(HRX::File)
    node.data.content
  end

  # Writes `content` to the file at `path`.
  #
  # If there's already a file at `path`, overwrites it. Otherwise, creates a new
  # file after the nearest file in the archive.
  #
  # If `comment` is passed, it's used as the comment for the new file. The
  # special value `:copy` copies the existing comment for the file, if there is
  # one.
  #
  # Throws an HRX::ParseError if `path` is invalid.
  #
  # Throws an HRX::Error if there's a directory at `path`.
  def write(path, content, comment: nil)
    components = path.split("/")
    nearest_dir = nil
    parent = components[0...-1].inject(@entries_by_path) do |hash, component|
      entry = hash[component]
      if entry.is_a?(LinkedList::Node)
        raise HRX::Error.new("\"#{entry.data.path}\" is a file")
      end

      # Even though both branches of this if are assignments, their return
      # values are used by #inject.
      if entry
        nearest_dir = entry
      else
        hash[component] = {}
      end
    end
    nearest_dir = parent unless parent.empty?

    previous = parent[components.last]
    if previous.is_a?(Hash)
      raise HRX::Error.new("\"#{path}/\" is a directory")
    end

    if previous.is_a?(LinkedList::Node)
      comment = previous.data.comment if comment == :copy
      previous.data = HRX::File.new(path, content, comment: comment)
      return
    end

    comment = nil if comment == :copy
    node = HRX::OrderedNode.new(HRX::File.new(path, content, comment: comment))
    if nearest_dir.nil?
      @entries << node
    else
      # Add the new file after its closest pre-existing cousin. Start looking
      # for siblings in `nearest_dir`, and then work down through its children.
      if last_cousin = _each_entry(nearest_dir).max_by {|n| n.order}
        @entries.insert_after_node(node, last_cousin)
      else
        @entries << node
      end
    end

    parent[components.last] = node
    nil
  end

  # Deletes the file or directory at `path`.
  #
  # Throws an HRX::Error if there's no entry at `path`.
  def delete(path, recursive: false)
    # The outermost parent directory hash that contains only the entry at
    # `path`, from which key_to_delete should be deleted
    parent_to_delete_from = nil
    key_to_delete = nil

    components = path.split("/")
    parent = components[0...-1].inject(@entries_by_path) do |hash, component|
      entry = hash[component]
      if entry.is_a?(LinkedList::Node)
        raise HRX::Error.new("\"#{entry.data.path}\" is a file")
      end

      if entry.nil?
        raise HRX::Error.new("\"#{path}\" doesn't exist")
      elsif entry.size == 1
        parent_to_delete_from ||= hash
        key_to_delete ||= component
      else
        parent_to_delete_from = nil
        key_to_delete = nil
      end

      hash[component] ||= {}
    end
    parent_to_delete_from ||= parent
    key_to_delete ||= components.last

    node = parent[components.last]
    if node.nil?
      raise HRX::Error.new("\"#{path}\" doesn't exist")
    elsif node.is_a?(Hash)
      if recursive
        _each_entry(node) {|n| @entries.unlink(n)}
      else
        unless node = node[:dir]
          raise HRX::Error.new("\"#{path}\" is not an explicit directory and recursive isn't set")
        end
        @entries.unlink(node)
      end
    elsif path.end_with?("/")
      raise HRX::Error.new("\"#{path}\" is a file")
    else
      @entries.unlink(node)
    end

    parent_to_delete_from.delete(key_to_delete)
  end

  # Sets the text of the last comment in the document.
  #
  # Throws an Encoding::UndefinedConversionError if `comment` can't be converted
  # to UTF-8.
  def last_comment=(comment)
    @last_comment = comment.encode("UTF-8")
  end

  # Adds an HRX::File or HRX::Directory to this archive.
  #
  # If `before` or `after` is passed, this adds `entry` before or after the
  # entry with the given path in the archive. If the archive has no entry with
  # the given path, this throws an HRX::Error. If `before` and `after` are
  # *both* passed, this throws an ArgumentError.
  #
  # Throws an HRX::Error if the entry conflicts with an existing entry.
  def add(entry, before: nil, after: nil)
    raise ArgumentError.new("before and after may not both be passed") if before && after

    node = HRX::OrderedNode.new(entry)

    path = entry.path.split("/")
    parent = path[0...-1].inject(@entries_by_path) do |hash, component|
      if hash[component].is_a?(LinkedList::Node)
        raise HRX::Error.new("\"#{entry.data.path}\" is a file")
      end
      hash[component] ||= {}
    end

    if parent[path.last].is_a?(HRX::File)
      raise HRX::Error.new("\"#{entry.path}\" defined twice")
    end

    if entry.is_a?(HRX::Directory)
      dir = (parent[path.last] ||= {})
      if dir.is_a?(LinkedList::Node) || dir[:dir]
        raise HRX::Error.new("\"#{entry.path}\" defined twice")
      end
      dir[:dir] = node
    else
      raise HRX::Error.new("\"#{entry.path}\" defined twice") if parent.has_key?(path.last)
      parent[path.last] = node
    end

    if before || after
      reference = _find_node(before || after)
      raise HRX::Error.new("There is no entry named \"#{before || after}\"") if reference.nil?

      if before
        @entries.insert_before_node(node, reference)
      else
        @entries.insert_after_node(node, reference)
      end
    else
      @entries << node
    end

    nil
  end
  alias_method :<<, :add

  # Returns this archive, serialized to text in HRX format.
  def to_hrx
    buffer = String.new.encode("UTF-8")
    boundary = "<#{"=" * _choose_boundary_length}>"

    entries.each_with_index do |e, i|
      buffer << boundary << "\n" << e.comment << "\n" if e.comment
      buffer << boundary << " " << e.path << "\n"
      if e.respond_to?(:content) && !e.content.empty?
        buffer << e.content
        buffer << "\n" unless i == entries.length - 1
      end
    end
    buffer << boundary << "\n" << last_comment << "\n" if last_comment

    buffer.freeze
  end

  private

  # Returns the LinkedList::Node at the given `path`, or `nil` if there is no
  # node at that path.
  def _find_node(path)
    components = path.split("/")
    return if components.empty?
    result = @entries_by_path.dig(*components)
    return result[:dir] if result.is_a?(Hash)
    return result unless path.end_with?("/")
  end

  # Returns each entry in or beneath the directory hash `dir`, in no particular
  # order.
  def _each_entry(dir)
    return to_enum(__method__, dir) unless block_given?

    dir.values.each do |entry|
      if entry.is_a?(Hash)
        _each_entry(entry) {|e| yield e}
      else
        yield entry
      end
    end
  end

  # Returns a boundary length for a serialized archive that doesn't conflict
  # with any of the files that archive contains.
  def _choose_boundary_length
    forbidden_boundary_lengths = Set.new
    entries.each do |e|
      [
        (e.content if e.respond_to?(:content)),
        e.comment
      ].each do |text|
        next unless text
        text.scan(/^<(=+)>/m).each do |(equals)|
          forbidden_boundary_lengths << equals.length
        end
      end
    end

    boundary_length = @boundary_length
    while forbidden_boundary_lengths.include?(boundary_length)
      boundary_length += 1
    end
    boundary_length
  end
end
