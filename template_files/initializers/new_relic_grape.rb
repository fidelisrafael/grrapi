# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      module GrapeInstrumentation
        def name_for_transaction(route, class_name)
          action_name = route.path.sub(FORMAT_REGEX, EMPTY_STRING)
          method_name = route.request_method

          if route.version
            action_name = action_name.sub(VERSION_REGEX, EMPTY_STRING)
            "#{class_name}-#{route.version}#{action_name} (#{method_name})"
          else
            "#{class_name}#{action_name} (#{method_name})"
          end
        end
      end
    end
  end
end
