require 'parser'
require 'parser/current'

#
# Given filename (file path) and line number,
# return whold method containing certain LOC
#
class MethodFinder
  def initialize(filename)
    @filename = filename
    @ast = parse(@filename)
  end

  #
  # Extract certain LOC according to the line number
  #
  def extract_content(num_of_line)
    target_line = ''
    # target method declare line will record
    # the first line of the method which target line belongs to.
    # target method declare line is to make sure
    # if the target line appear multiple times in one file
    # the return value will be the correct method block instead of
    # the last method block including target line
    target_method_declare_line = ''
    File.readlines(@filename).each_with_index do |line, line_num|
      target_method_declare_line = line.lstrip if line.lstrip.start_with? 'def '
      if num_of_line == line_num + 1
        target_line = line
        break
      end
    end
    [target_line, target_method_declare_line]
  end

  #
  # Find the whole method containing certain LOC
  #
  def find(num_of_line)
    target_line, target_method_declare_line = extract_content(num_of_line)
    recursive_search_ast(@ast, target_line, target_method_declare_line)
    return @method_source
  end

  private
  #
  # Parse file into AST
  #
  def parse(filename)
    Parser::CurrentRuby.parse(File.open(filename, "r").read)
  end

  #
  # Recursively search AST to return the whole method containing certain LOC
  #
  def recursive_search_ast(ast, target_line, target_method_declare_line)
    ast.children.each do |child|
      if child.class.to_s == "Parser::AST::Node"
        if (child.type.to_s == "def" or child.type.to_s == "defs") and 
          child.loc.expression.source.include? target_line and 
          child.loc.expression.source.start_with? target_method_declare_line
          @method_source = child.loc.expression.source
          break
        else
          recursive_search_ast(child, target_line, target_method_declare_line)
        end
      end
    end
  end
end

# mf = MethodFinder.new("../../expertiza/app/controllers/submitted_content_controller.rb")
# puts mf.find(35)