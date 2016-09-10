module Danger
  #
  # This is a danger plugin to detect any TODO/FIXME entries left in the code.
  #
  # @example Ensure, by warning, there are no TODOS left in the modified code
  #
  #          todoist.warn_for_todos
  #
  # @example Ensure, by failing the build, no TODOS left in the modified code
  #
  #          todoist.fail_for_todos
  #
  # @example Set custom warning message for warning
  #
  #          todoist.message = "Please fix all TODOS"
  #          todoist.warn_for_todos
  #
  # @example List every todo item
  #
  #          todoist.warn_for_todos
  #          todoist.print_todos_table
  #
  # @example Do anything with the todos. Todos have `text` and `file` properties
  #
  #          todoist.todos.each { |todo| puts todo.text }
  #
  # @see  hanneskaeufler/danger-todoist
  # @tags todos, fixme
  #
  class DangerTodoist < Plugin
    DEFAULT_MESSAGE = "There remain todo items in the modified code.".freeze

    #
    # Message to be shown
    #
    # @attr_writer [String] message Custom message shown when todos were found
    # @return [void]
    #
    attr_writer :message

    #
    # Adds a warning if there are todos found in the modified code
    #
    # @return [void]
    #
    def warn_for_todos
      call_method_for_todos(:warn)
    end

    #
    # Adds an error if there are todos found in the modified code
    #
    # @return [void]
    #
    def fail_for_todos
      call_method_for_todos(:fail)
    end

    #
    # Adds a list of offending files to the danger comment
    #
    # @return [void]
    #
    def print_todos_table
      find_todos if @todos.nil?
      return if @todos.empty?

      markdown("#### Todos left in files")

      @todos
        .group_by(&:file)
        .each { |file, todos| print_todos_per_file(file, todos) }
    end

    #
    # Returns the list of todos in the current diff set
    #
    # @return [Array of todos]
    #
    def todos
      find_todos if @todos.nil?
      @todos
    end

    private

    def print_todos_per_file(file, todos)
      markdown("- #{file}")
      todos
        .select(&:text)
        .each { |todo| markdown("  - #{todo.text}") }
    end

    def call_method_for_todos(method)
      find_todos if @todos.nil?
      public_send(method, message, sticky: false) unless @todos.empty?
    end

    def find_todos
      @todos = []
      return if files_of_interest.empty?

      @todos = DiffTodoFinder.new.find_diffs_containing_todos(diffs_of_interest)
    end

    def message
      return @message unless @message.nil?
      DEFAULT_MESSAGE
    end

    def files_of_interest
      git.modified_files + git.added_files
    end

    def diffs_of_interest
      files_of_interest
        .map { |file| git.diff_for_file(file) }
    end
  end
end
