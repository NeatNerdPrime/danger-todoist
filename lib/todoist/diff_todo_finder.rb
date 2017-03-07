module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords)
      @keywords = keywords
    end

    # TODO: this must be cleaned up
    # by quite a bit
    def find_diffs_containing_todos(diffs)
      todos = []
      regexp = todo_regexp
      diffs.each do |diff|
        matches = diff.patch.scan(regexp)
        next if matches.empty?

        matches.each do |match|
          todos << Danger::Todo.new(diff.path, clean_todo_text(match))
        end
      end
      todos
    end

    private

    def clean_todo_text(match)
      comment_indicator, _, entire_todo, _, rest = match
      entire_todo.gsub(rest || "", "")
                 .gsub(comment_indicator, "")
                 .delete("\n")
                 .strip
    end

    def todo_regexp
      /
      (?<comment_indicator>^\+\s*[^a-z0-9\+\s]+)
      (\n\+)?\s+
      (?<todo_indicator>#{@keywords.join("|")})[\s:]{1}
      (?<entire_text>(?<text>[^\n]*)
      (?<rest>\n\k<comment_indicator>\s*[^\n]*)*)
      /ixm
    end
  end
end
