// Copyright 2020 Sebastian Kuerten
//
// This file is part of hrx-java.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package de.topobyte.hrx;

import java.io.IOException;

class LineSupplier
{

	private Line buffer = null;
	private LineReader reader;

	public LineSupplier(LineReader reader)
	{
		this.reader = reader;
	}

	public Line next() throws IOException
	{
		if (buffer != null) {
			Line tmp = buffer;
			buffer = null;
			return tmp;
		}
		return reader.readLine();
	}

	public void push(Line line)
	{
		buffer = line;
	}

}
