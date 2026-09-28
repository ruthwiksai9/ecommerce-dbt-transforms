{% macro date_trunc_to_period(column, period='month') %}
    date_trunc('{{ period }}', {{ column }})::date
{% endmacro %}
