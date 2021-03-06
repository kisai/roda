require_relative "../spec_helper"

begin
  require 'tilt/erb'
rescue LoadError
  warn "tilt not installed, skipping precompiled_templates plugin test"  
else
describe "precompile_templates plugin" do 
  it "adds support for template precompilation" do
    app(:bare) do
      plugin :render, :views=>'spec/views'
      plugin :precompile_templates
      route do |r|
        @a = 1
        render('iv')
      end
    end

    app.render_opts[:cache][File.expand_path('spec/views/iv.erb')].must_be_nil
    app.precompile_templates 'spec/views/iv.erb'
    app.render_opts[:cache][File.expand_path('spec/views/iv.erb')].wont_equal nil
    app.render_opts[:cache][File.expand_path('spec/views/iv.erb')].instance_variable_get(:@compiled_method).length.must_equal 1
    body.strip.must_equal '1'
    app.render_opts[:cache][File.expand_path('spec/views/iv.erb')].instance_variable_get(:@compiled_method).length.must_equal 1
  end

  it "adds support for template precompilation with :locals" do
    app(:bare) do
      plugin :render, :views=>'spec/views'
      plugin :precompile_templates
      route do |r|
        render('about', :locals=>{:title=>'1'})
      end
    end

    app.render_opts[:cache][File.expand_path('spec/views/about.erb')].must_be_nil
    app.precompile_templates 'spec/views/about.erb', :locals=>[:title]
    app.render_opts[:cache][File.expand_path('spec/views/about.erb')].wont_equal nil
    app.render_opts[:cache][File.expand_path('spec/views/about.erb')].instance_variable_get(:@compiled_method).length.must_equal 1
    body.strip.must_equal '<h1>1</h1>'
    app.render_opts[:cache][File.expand_path('spec/views/about.erb')].instance_variable_get(:@compiled_method).length.must_equal 1
  end

  it "adds support for template precompilation with :inline" do
    app(:bare) do
      plugin :render, :views=>'spec/views'
      plugin :precompile_templates
      route do |r|
        render(:inline=>'a', :cache_key=>'a')
      end
    end

    app.render_opts[:cache]['a'].must_be_nil
    app.precompile_templates :inline=>'a', :cache_key=>'a'
    app.render_opts[:cache]['a'].wont_equal nil
    app.render_opts[:cache]['a'].instance_variable_get(:@compiled_method).length.must_equal 1
    body.strip.must_equal "a"
    app.render_opts[:cache]['a'].instance_variable_get(:@compiled_method).length.must_equal 1
  end
end
end
