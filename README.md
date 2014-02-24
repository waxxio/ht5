# HT5

HT5 is an HTML5 generation library that makes it easy to join Ruby code with HTML output. 
It is similar to Tagz, but is for HTML5 only and does not use **method_missing** so it is quite a bit faster. 
If you require arbitrary tag names (like for an XML file) then you should use Tagz. 

Here is an example. See test/test_ht5.rb for more:

    require "ht5"

    class Layout

      include HT5

      def data
        [%w( 1 2 3 ), %w(4 5 6), %w(7 8 9)]
      end

      def doc
        doctype_
        html_{
          head_{
            comment_{"This is a comment"}
            title_{"A Page"}
            meta_(name:"robots", content:"index,follow")
            script_(type:"text/javascript"){%<alert("Hello from HT5");>}
          }
          body_{
            h1_{"A web page"}
            section_(id:"one"){
              article_{
                p_{"This is an article."}
                blockquote_{h_("<b>Joe said:</b> <i>\"Hello 'Jan' & 'Jane'.\"</i>")}
              }
              link = "http://waxx.co/a b.html?d=$;x=1;y=2&z=`~!@#\$%^&*()_+=-{}[]|\'\";<>,.?/"
              a_(href: "/goto?url=#{url_(link)};remote=true"){"Link"}
            }
            # Call a method to inject more content
            data_table
            _{"This is plain text."}
            tag_(:new, style:"font-weight:bold"){"This is a new tag"}
          }
        }
        ht5.to_s
      end

      def data_table
        table_(id:"one"){
          thead_{
            tr_{
              th_{"One"}
              th_{"Two"}
              th_{"Three"}
            }
          }
          tbody_{
            data.each{|row|
              tr_{
                td_{div_{row[0]}}
                td_{span_{row[1]}}
                td_{p_{row[2]}}
              }
            }
          }
          tfoot_{
            tr_{
              td_(colspan:3){"the footer"}
            }
          }
        }
      end
    end

    Layout.new.doc

In the above example, the HT5 mixin will add the **@ht5** attribute (a
type of Array) and all of the HTML5 methods. When you call a method, 
the @ht5 attribute is appended to. Call ht5.to_s to join the array.


## Closing Tag Method

If you prefer, you can use closing tag names \_html, \_body, etc rather
than blocks. This is useful if you like to see the name of the closing
tag or you have methods that add open and closing tags independently. 
Use blocks when you want text output between tags.

    doctype_
    html_
      head_
        title_{"A Page"}
        meta_(name:"robots", content:"index,follow")
        script_(type:"text/javascript"){%<alert("Hello from HT5");>}
      _head
      body_
        h1_{"A web page"}
        section_(id:"one")
          article_
            p_{"This is an article."}
            blockquote_{"and Joe said..."}
          _article
        _section
      _body
    _html

## Rack Example

_config.ru:_

    require 'ht5'

    class App

      include HT5

      def call(env)
        req = Rack::Request.new(env)
        doctype_
        html_{
          head_{
            title_{"Hello"}
            meta_(name:"robots", content:"index,follow")
            script_(type:"text/javascript"){"alert('Hello from HT5');"}
          }
          body_{
            h1_{"Hello From HT5"}
            # This is a Ruby comment. It will not be displayed in the output.
            _!{"This is an HTML comment."}
            comment_{"This will be displayed too."}
            div_{"This is <b>some escaped user input:</b> #{h_(req.params['x'])}"}
            p_(id:"one"){"This is some text"}
            div_{
              i_{"Time: "}
              b_{Time.now}
            }
            span_{false}
            _{" "}
            span_{true}
            _{" "}
            span_{nil}
          }
        }
        [200,{},@ht5]
      end
    end

    run App.new

You can then run `thin start -R config.ru -p 8000` to run the app and view at <http://localhost:8000/>.
Since Rack takes an Array type object for the response there is no need to call _to_s_ before returning the value.

Response to <http://localhost:8000/?x=\<x\>>: (Formatted for easy viewing. Actual output on one line.)

    <!DOCTYPE html>
	<html>
		<head>
			<title>Hello</title>
			<meta name="robots" content="index,follow">
			<script type="text/javascript">alert('Hello from HT5');</script>
		</head>
		<body>
			<h1>Hello From HT5</h1>
			<!-- This is an HTML comment. -->
			<!-- This will be displayed too. -->
			<div>This is some bold and escaped user input: <b>&lt;x&gt;</b></div>
			<p id="one">This is some text</p>
			<div>
				<i>Time: </i>
				<b>2014-02-24 13:31:31 -0700</b>
			</div>
			<span>false</span> 
			<span>true</span> 
			<span></span>
		</body>
	</html>

## Supported Tags

The following tags are supported (all HTML5):

`a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption
cite code col colgroup data datagrid datalist dd del details dfn dialog div dl dt em embed eventsource fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hr html i
iframe img input ins kbd keygen label legend li link main mark map menu menuitem meta meter nav
noscript object ol optgroup option output p param pre progress q ruby rp rt s samp script section
select small source span strong style sub summary sup table tbody td textarea tfoot th thead time
title tr track u ul var video wbr`

In addition, you can use `doctype_` and comments: `comment_` and `_!`.

## Install

	gem install ht5
    ~ or ~
    sudo gem install ht5


## Author
HT5 was written by Dan Fitzpatrick. More info on HT5 at [GitHub](https://github.com/dfitzpat/ht5).

## License
HT5 is released under the terms of the Apache License Version 2. See the LICENCE file.

