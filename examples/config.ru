require 'ht5'

class App

  include HT5

  def call(env)
    req = Rack::Request.new(env)
    doctype_
    html_
      head_
        title_{"Hello"}
        meta_(name:"robots", content:"index,follow")
        script_(type:"text/javascript"){"alert('Hello from HT5');"}
      _head
      body_
        h1_{"Hello From HT5"}
        # This is a Ruby comment. It will not be displayed in the output.
        _!{"This is an HTML comment."}
        comment_{"This will be displayed too."}
        div_{"This is some bold and escaped user input: <b>#{h_(req.params['x'])}</b>"}
        p_(id:"one"){"This is some text"}
        div_
          i_{"Time: "}
          b_{Time.now}
        _div
        span_{false}
        _{" "}
        span_{true}
        _{" "}
        span_{nil}
      _body
    _html
    [200, {}, ht5]
  end
end

run App.new

# To run: thin start -R config.ru -p 8000
# http://localhost:8000/?x=<x>
