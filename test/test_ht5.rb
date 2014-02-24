gem "minitest"
require "minitest/autorun"
require "./lib/ht5"

class TestHT5 < Minitest::Test

  include HT5

  def test_comment
    start_ht5
    comment_{"This is a comment"}
    _!{"Another"}
    assert_equal "<!-- This is a comment --><!-- Another -->", ht5.to_s
  end

  def test_no_tag
    start_ht5
    _{"This is plain text. "}
    __{"more"}
    assert_equal "This is plain text. more", ht5.to_s
  end

  def test_doctype
    doctype_
    assert_equal "<!DOCTYPE html>", ht5.to_s
  end

  def test_escape_html
    start_ht5
    p_{h_("<b>Joe said:</b> <i>\"Hello 'Jan' & 'Jane'.\"</i>")}
    assert_equal "<p>&lt;b&gt;Joe said:&lt;/b&gt; &lt;i&gt;&quot;Hello &#39;Jan&#39; &amp; &#39;Jane&#39;.&quot;&lt;/i&gt;</p>", ht5.to_s
  end

  def test_escape_url
    start_ht5
    a_(href: "/goto?url=#{url_("http://waxx.co/a b.html?d=$;x=1;y=2&z=`~!@#\$%^&*()_+=-{}[]|\'\";<>,.?/;")};remote=true"){"Link"}
    assert_equal %(<a href="/goto?url=http%3A%2F%2Fwaxx.co%2Fa+b.html%3Fd%3D%24%3Bx%3D1%3By%3D2%26z%3D%60%7E%21%40%23%24%25%5E%26%2A%28%29_%2B%3D-%7B%7D%5B%5D%7C%27%22%3B%3C%3E%2C.%3F%2F%3B;remote=true">Link</a>), ht5.to_s
  end

  def test_undefined_tag
    start_ht5
    tag_(:new, style:"font-weight:bold"){"This is a new tag"}
    tag_(:x)
    _{"txt"}
    _tag(:x)
    assert_equal %(<new style="font-weight:bold">This is a new tag</new><x>txt</x>), ht5.to_s
  end

  def test_all_tags
    start_ht5
    %w(
    a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption
    cite code col colgroup data datagrid datalist dd del details dfn dialog div dl dt em embed
    eventsource fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hr html i
    iframe img input ins kbd keygen label legend li link main mark map menu menuitem meta meter nav
    noscript object ol optgroup option output p param pre progress q ruby rp rt s samp script section
    select small source span strong style sub summary sup table tbody td textarea tfoot th thead time
    title tr track u ul var video wbr
    ).each{|el|
      send("#{el}_")
      send("_#{el}")
    }
    assert_equal %(<a></a><abbr></abbr><address></address><area></area><article></article><aside></aside><audio></audio><b></b><base></base><bdi></bdi><bdo></bdo><blockquote></blockquote><body></body><br></br><button></button><canvas></canvas><caption></caption><cite></cite><code></code><col></col><colgroup></colgroup><data></data><datagrid></datagrid><datalist></datalist><dd></dd><del></del><details></details><dfn></dfn><dialog></dialog><div></div><dl></dl><dt></dt><em></em><embed></embed><eventsource></eventsource><fieldset></fieldset><figcaption></figcaption><figure></figure><footer></footer><form></form><h1></h1><h2></h2><h3></h3><h4></h4><h5></h5><h6></h6><head></head><header></header><hr></hr><html></html><i></i><iframe></iframe><img></img><input></input><ins></ins><kbd></kbd><keygen></keygen><label></label><legend></legend><li></li><link></link><main></main><mark></mark><map></map><menu></menu><menuitem></menuitem><meta></meta><meter></meter><nav></nav><noscript></noscript><object></object><ol></ol><optgroup></optgroup><option></option><output></output><p></p><param></param><pre></pre><progress></progress><q></q><ruby></ruby><rp></rp><rt></rt><s></s><samp></samp><script></script><section></section><select></select><small></small><source></source><span></span><strong></strong><style></style><sub></sub><summary></summary><sup></sup><table></table><tbody></tbody><td></td><textarea></textarea><tfoot></tfoot><th></th><thead></thead><time></time><title></title><tr></tr><track></track><u></u><ul></ul><var></var><video></video><wbr></wbr>), ht5.to_s
  end

  def test_table
    start_ht5
    table_(id:"one"){
      thead_{
        tr_{
          th_{"One"}
          th_{"Two"}
          th_{"Three"}
        }
      }
      tbody_{
        tr_{
          td_{div_{"1"}}
          td_{span_{"2"}}
          td_{p_{"3"}}
        }
        tr_{
          td_{div_{"1"}}
          td_{span_{"2"}}
          td_{p_{"3"}}
        }
      }
      tfoot_{
        tr_{
          td_(colspan:3){"the footer"}
        }
      }
    }
    assert_equal %(<table id="one"><thead><tr><th>One</th><th>Two</th><th>Three</th></tr></thead><tbody><tr><td><div>1</div></td><td><span>2</span></td><td><p>3</p></td></tr><tr><td><div>1</div></td><td><span>2</span></td><td><p>3</p></td></tr></tbody><tfoot><tr><td colspan="3">the footer</td></tr></tfoot></table>), ht5.to_s
  end

  def test_document_blocks
    doctype_
    html_{
      head_{
        title_{"A Page"}
        meta_(name:"robots", content:"index,follow")
        script_(type:"text/javascript"){%<alert("Hello from HT5");>}
      }
      body_{
        h1_{"A web page"}
        section_(id:"one"){
          article_{
            p_{"This is an article."}
            blockquote_{"and Joe said..."}
          }
        }
      }
    }
    assert_equal %(<!DOCTYPE html><html><head><title>A Page</title><meta name="robots" content="index,follow"><script type="text/javascript">alert("Hello from HT5");</script></head><body><h1>A web page</h1><section id="one"><article><p>This is an article.</p><blockquote>and Joe said...</blockquote></article></section></body></html>), ht5.to_s
  end

  def test_document_closing_tags
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
    assert_equal %(<!DOCTYPE html><html><head><title>A Page</title><meta name="robots" content="index,follow"><script type="text/javascript">alert("Hello from HT5");</script></head><body><h1>A web page</h1><section id="one"><article><p>This is an article.</p><blockquote>and Joe said...</blockquote></article></section></body></html>), ht5.to_s
  end
end
