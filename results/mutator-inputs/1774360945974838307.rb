class ImportFileController < ApplicationController
  def importFile(session, params)
    delimiter = get_delimiter(params)
    file = params['file'].tempfile

    errors = []
    first_row_read = false
    row_header = {}
    file.each_line do |line|
      line.chomp!
      if first_row_read == false
        row_header = parse_line(line.downcase, delimiter)
        first_row_read = true
        if row_header.include?("email")
          # skip if first row contains header. In case of user information, it will contain name of user (mandatory
          next
        else
          row_header = {}
        end
      end
      next if line.empty?
      row = parse_line(line, delimiter)
      begin
        if params[:model] == 'AssignmentTeam' or params[:model] == 'CourseTeam'
          Object.const_get(params[:model]).import(row, params[:id], params[:options])
        elsif params[:model] == 'SignUpTopic'
          session[:assignment_id] = params[:id]
          Object.const_get(params[:model]).import(row, session, params[:id])
        else
          if row_header.count > 0
            Object.const_get(params[:model]).import(row, row_header, session, params[:id])
          else
            Object.const_get(params[:model]).import(row, nil, session, params[:id])
          end
        end
      rescue
        errors << $ERROR_INFO
      end
    end
    errors
  end
end
