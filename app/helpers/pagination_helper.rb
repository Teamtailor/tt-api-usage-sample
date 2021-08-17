module PaginationHelper
  def pages_to_display(current_page, max_page)
    first_page = current_page.to_i - 3
    last_page = current_page.to_i + 3
    (first_page..last_page).select { |page| page >= 1 && page <= max_page }
  end
end
