require File.dirname(__FILE__) + '/../test_helper'

class PluginManagerTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @controller = mock()
    @controller.stubs(:profile).returns()
    @controller.stubs(:request).returns()
    @controller.stubs(:response).returns()
    @controller.stubs(:params).returns()
    @manager = Noosfero::Plugin::Manager.new(@environment, @controller)
  end
  attr_reader :environment
  attr_reader :manager

  should 'give access to environment and context' do
    assert_same @environment, @manager.environment
    assert_same @controller, @manager.context
  end

  should 'return the intersection between environment\'s enabled plugins and system available plugins' do
    class Plugin1 < Noosfero::Plugin; end;
    class Plugin2 < Noosfero::Plugin; end;
    class Plugin3 < Noosfero::Plugin; end;
    class Plugin4 < Noosfero::Plugin; end;
    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s, Plugin4.to_s])
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin3.to_s, Plugin4.to_s])
    plugins = manager.enabled_plugins.map { |instance| instance.class.to_s }
    assert_equal [Plugin1.to_s, Plugin4.to_s], plugins
  end

  should 'map events to registered plugins' do

    class Noosfero::Plugin
      def random_event
        nil
      end
    end

    class Plugin1 < Noosfero::Plugin
      def random_event
        'Plugin 1 action.'
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        'Plugin 2 action.'
      end
    end

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s])

    p1 = Plugin1.new
    p2 = Plugin2.new

    assert_equal [p1.random_event, p2.random_event], manager.dispatch(:random_event)
  end

  should 'return the first non-blank result' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        'Plugin2'
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        'Plugin3'
      end
    end

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    Plugin3.any_instance.expects(:random_event).never

    assert 'Plugin2', manager.first(:random_event)
  end

  should 'returns plugins that returns true to the event' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        true
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        true
      end
    end

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    results = manager.dispatch_plugins(:random_event)

    assert_includes results, Plugin2
    assert_includes results, Plugin3
  end

  should 'return the first plugin that returns true' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        true
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        true
      end
    end

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    Plugin3.any_instance.expects(:random_event).never

    assert_equal Plugin2, manager.first_plugin(:random_event)
  end

  should 'use default value defined on the base plugin class when no plugin enabled for the first method' do
    class Noosfero::Plugin
      def random_event
        1
      end
    end

    assert_equal 1, manager.first(:random_event)
  end

end

