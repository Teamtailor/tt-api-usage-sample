class QueryBuilder
  def run(params)
    { filter: params.transform_keys { |key| key.gsub('_', '-') } }
  end
end
