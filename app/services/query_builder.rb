class QueryBuilder
  def run(params)
    deep_compact(transform(params))
  end

  private

  def transform(params)
    transformed_params = Hash.new { |h, k| h[k] = {} }.tap do |hash|
      params.each do |param_key, param_value|
        if param_key.include?('_from')
          hash[param_key.remove('_from').dasherize]['from'] = param_value
        elsif param_key.include?('_to')
          hash[param_key.remove('_to').dasherize]['to'] = param_value
        else
          hash[param_key.dasherize] = param_value
        end
      end
    end
    { filter: transformed_params }
  end

  def deep_compact(hash)
    hash.compact.transform_values do |value|
      next value unless value.is_a? Hash

      deep_compact(value)
    end.reject { |_k, v| v.blank? }
  end
end
