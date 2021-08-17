class QueryBuilder
  def run(params)
    deep_compact(key_transform(params))
  end

  private

  def key_transform(params)
    { filter: { created_at: { from: params[:created_at_from], to: params[:created_at_to] }, email: params[:email] }}
  end

  def deep_compact(h)
    h.each { |_, v| deep_compact(v) if v.is_a? Hash }.reject! { |_, v| v.blank? }
  end
end
