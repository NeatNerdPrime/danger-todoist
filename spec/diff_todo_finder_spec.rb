require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DiffTodoFinder do
    let(:subject) { Danger::DiffTodoFinder.new }

    describe "#find_diffs_containing_todos" do
      %w(TODO TODO: todo todo: FIXME fixme FIXME: fixme).each do |marker|
        it "identifies a new '#{marker}' as a todo" do
          diffs = [
            Git::Diff::DiffFile.new(
              "base",
              path:  "some/file.rb",
              patch: "+ #{marker} some todo"
            )
          ]

          todos = subject.find_diffs_containing_todos(diffs)

          expect(todos).to_not be_empty
        end
      end

      it "does not identify removed todos as a todo" do
        diffs = [
          Git::Diff::DiffFile.new(
            "base",
            path:  "some/file.rb",
            patch: "- TODO: some todo"
          )
        ]

        todos = subject.find_diffs_containing_todos(diffs)

        expect(todos).to be_empty
      end

      [
        "+ class TodosController",
        "+ function foo(todo) {",
        "+ def todo()"
      ].each do |patch|
        it "does not identify occurences in e.g. a new class name" do
          diffs = [
            Git::Diff::DiffFile.new(
              "base",
              path:  "some/file.rb",
              patch: patch
            )
          ]

          todos = subject.find_diffs_containing_todos(diffs)

          expect(todos).to be_empty
        end
      end
    end
  end
end
