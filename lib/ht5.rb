#  Copyright 2014 ePark Labs Inc
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

module HT5

  VERSION = "0.1.1"

  class HT5OUT < ::Array
    def to_s
      join
    end
  end

  # The container that holds the output.
  def ht5
    @ht5 ||= start_ht5
  end

  def start_ht5
    @ht5 = ::HT5::HT5OUT.new
  end

  # Add a <!-- comment -->
  # Usage: comment_{"This is a comment."}
  def comment_(&b)
    ht5 << "<!-- #{yield} -->"
  end
  alias _! comment_

  # Add a string with no tags (or your own tags)
  def __(&b)
    ht5 << yield
  end

  alias _ __

  # Adds the HTML5 DOCTYPE tag
  def doctype_
    start_ht5
    ht5 << "<!DOCTYPE html>"
  end

  # Escape HTML
  # Returns an escaped string for ['"&<>]
  def h_(str)
    str.to_s.gsub(/['&\"<>]/, {"'"=>"&#39;", "&"=>"&amp;", '"'=>"&quot;", "<"=>"&lt;", ">"=>"&gt;"})
  end

  # Escape URL query string
  # Returns an escaped string for all characters except [a-zA-Z0-9_.-]
  def url_(str)
    encoding = str.encoding
    str.b.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      '%' + m.unpack('H2' * m.bytesize).join('%').upcase
    end.tr(' ', '+').force_encoding(encoding)
  end

  # Support other tags
  # Usage: tag_(:person, class: 'active'){"Joe"}
  # Returns: <person class="active">Joe</person>
  def tag_(el, opts={}, &b)
    ht5 << "<#{el}#{opts.map{|n,v| " #{n}=\"#{v}\""}.join}>"
    if block_given?
      ht5 << yield
      ht5 << "</#{el}>"
    end
    nil
  end

  def _tag(el)
    ht5 << "</#{el}>"
    nil
  end

  %w(
    a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption
    cite code col colgroup data datagrid datalist dd del details dfn dialog div dl dt em embed
    eventsource fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hr html i
    iframe img input ins kbd keygen label legend li link main mark map menu menuitem meta meter nav
    noscript object ol optgroup option output p param pre progress q ruby rp rt s samp script section
    select small source span strong style sub summary sup table tbody td textarea tfoot th thead time
    title tr track u ul var video wbr
  ).each{|el|
    opts = '#{opts.map{|n,v| " #{n}=\"#{v}\""}.join}'
    tag = <<-EL
    def #{el}_ opts={}, &b
      ht5 << "<#{el}#{opts}>"
      if block_given?
        ht5 << yield
        ht5 << "</#{el}>"
      end
      nil
    end
    def _#{el}
      ht5 << "</#{el}>"
      nil
    end
    EL
    eval tag
  }
end

# Handle both cases HT5 and Ht5
module Ht5
  include HT5
end
