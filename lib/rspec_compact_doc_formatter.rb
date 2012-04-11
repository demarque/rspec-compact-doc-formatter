require 'rspec/core/formatters/base_text_formatter'

class RspecCompactDocFormatter < RSpec::Core::Formatters::BaseTextFormatter
  def initialize(output)
    super(output)
    @group_level = 0
  end

  def current_indentation
    '  ' * @group_level
  end

  def dump_commands_to_rerun_failed_examples
    # Hidden
  end

  def dump_pending
    # Hidden
  end

  def example_group_started(example_group)
    super(example_group)

    description = example_group.description

    if @group_level == 0
      output_class_name description
    elsif method_name? description
      output_prelude_and_method description
    elsif @method_position and @group_level > @method_position
      output_fixture description
    else
      @prelude += description + ' '
    end

    @group_level += 1
  end

  def example_group_finished(example_group)
    @group_level -= 1
  end

  def example_passed(example)
    super(example)
    output.puts passed_output(example)
  end

  def example_pending(example)
    super(example)
    output.puts pending_output(example, example.execution_result[:pending_message])
  end

  def example_failed(example)
    super(example)
    output.puts failure_output(example, example.execution_result[:exception])
  end

  def failure_output(example, exception)
    one_liner_description example, 'red'
  end

  def method_name?(description)
    description[0,1] == '#' or description[0,2] == '::'
  end

  def next_failure_index
    @next_failure_index ||= 0
    @next_failure_index += 1
  end

  def one_liner_description(example, color='green')
    content = { :assertion => [], :result => '', :subject => 'it' }

    if example_group
      example_group.ancestors.reverse.each_with_index do |a, i|
        if i <= @start_position
          nil
        elsif i != @start_position + 1 and a.description[0,4] == 'when'
          content[:assertion] << ", #{a.description}"
        elsif not ['and', 'having', 'when', 'with', 'without'].include? a.description.split(' ')[0] and (i+1) == example_group.ancestors.length
          content[:subject] = a.description
        else
          content[:assertion] << " #{a.description}"
        end
      end
    end

    content[:subject] = "\e[35m#{content[:subject]}\e[0m "
    content[:subject] = ', ' + content[:subject] if content[:assertion].length > 0

    content[:result] = example.description.to_s.empty? ? 'FAILED' : example.description

    return (@start_position == 1 ? '    ' : '      ') + content[:assertion].join + content[:subject] + self.send(color, content[:result])
  end

  def output_class_name(description)
    output.puts "\n" + description
    @prelude = ''
  end

  def output_fixture(description)
    if description.include? 'with the fixture'
      @start_position += 1

      output.puts current_indentation + description.split(':')[0] + "\e[1;33m" + description.split(':')[1] + "\e[0m"
    end
  end

  def output_prelude_and_method(description)
    indent_method = @prelude.empty? ? '  ' : '    '

    if @method_position and @method_position > 1
      if @group_level == 1
        output.puts " "
      else
        indent_method = '    '
      end
    end

    if not @prelude.empty?
      output.puts "\n  " + @prelude
      @prelude = ''
    end

    output.puts indent_method + cyan(description)

    @method_position = @group_level
    @start_position = @method_position
  end

  def passed_output(example)
    one_liner_description example, 'green'
  end

  def pending_output(example, message)
    indent = (@start_position and @start_position > 1) ? '      ' : '    '
    yellow("#{indent}#{example.description} (PENDING: #{message})")
  end
end
