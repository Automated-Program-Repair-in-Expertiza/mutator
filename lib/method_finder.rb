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
    i = 1
    target_line = ''
    File.open(@filename, 'r') do |f|
      f.each_line do |line|
        if i != num_of_line
          i += 1
        else
          target_line = line
          break
        end
      end
    end
    target_line
  end

  #
  # Find the whole method containing certain LOC
  #
  def find(num_of_line)
    content_of_line = extract_content(num_of_line)
    recursive_search_ast(@ast, content_of_line)
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
  def recursive_search_ast(ast, content_of_line)
    ast.children.each do |child|
      if child.class.to_s == "Parser::AST::Node"
        if (child.type.to_s == "def" or child.type.to_s == "defs") and 
          child.loc.expression.source.include? content_of_line
          @method_source = child.loc.expression.source
        else
          recursive_search_ast(child, content_of_line)
        end
      end
    end
  end
end

mf = MethodFinder.new("../../expertiza/app/controllers/submitted_content_controller.rb")
puts mf.find(245)