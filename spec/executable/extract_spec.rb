# Copyright 2019 Google Inc
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

RSpec.describe "hrx extract", type: :aruba do
  before :each do
    write_file("archive.hrx", <<END)
<===> file1.txt
contents 1

<===> file2.txt
contents 2

<===> sub/file1.txt
sub contents 1

<===> sub/file2.txt
sub contents 2

END
  end

  context "extracts all files to a directory that" do
    it "is named after the HRX file" do
      run_command_and_stop "bin/hrx extract archive.hrx"

      expect("archive/file1.txt").to have_file_content("contents 1")
      expect("archive/file2.txt").to have_file_content("contents 2")
      expect("archive/sub/file1.txt").to have_file_content("sub contents 1")
      expect("archive/sub/file2.txt").to have_file_content("sub contents 2")
    end

    it "is named after the --directory option" do
      run_command_and_stop "bin/hrx extract --directory a/nother/dir archive.hrx"

      expect("a/nother/dir/file1.txt").to have_file_content("contents 1")
      expect("a/nother/dir/file2.txt").to have_file_content("contents 2")
      expect("a/nother/dir/sub/file1.txt").to have_file_content("sub contents 1")
      expect("a/nother/dir/sub/file2.txt").to have_file_content("sub contents 2")
    end
  end

  context "if the archive isn't named .hrx" do
    before :each do
      move "archive.hrx", "archive"
    end

    it "refuses to extract files to a default directory" do
      run_command "bin/hrx extract archive", fail_on_error: false
      expect(last_command_started).not_to be_successfully_executed
      expect(last_command_started.stderr).not_to include_a_stack_trace
    end

    it "extract files to --directory" do
      run_command_and_stop "bin/hrx extract --directory a/nother/dir archive"

      expect("a/nother/dir/file1.txt").to have_file_content("contents 1")
      expect("a/nother/dir/file2.txt").to have_file_content("contents 2")
      expect("a/nother/dir/sub/file1.txt").to have_file_content("sub contents 1")
      expect("a/nother/dir/sub/file2.txt").to have_file_content("sub contents 2")
    end
  end

  it "creates empty directories" do
    write_file("archive.hrx", <<END)
<===> dir1/
<===> dir2/sub/
END

    run_command_and_stop "bin/hrx extract archive.hrx"
    expect("archive/dir1").to be_an_existing_directory
    expect("archive/dir2/sub").to be_an_existing_directory
  end

  context "fails gracefully for" do
    it "an input file that doesn't exist" do
      run_command "bin/hrx extract no-file.hrx", fail_on_error: false
      expect(last_command_started).not_to be_successfully_executed
      expect(last_command_started.stderr).not_to include_a_stack_trace
    end

    it "an input file that's invalid HRX" do
      write_file("archive.hrx", "not HRX")
      run_command "bin/hrx extract archive.hrx", fail_on_error: false
      expect(last_command_started).not_to be_successfully_executed
      expect(last_command_started.stderr).not_to include_a_stack_trace
    end
  end
end
