with source as (
    select * from {{ source('raw', 'order_payments') }}
),

renamed as (
    select
        order_id,
        payment_sequential,
        lower(trim(payment_type))               as payment_type,
        payment_installments::int               as installments,
        payment_value::numeric(10, 2)           as payment_value,
        payment_installments > 1                as is_installment_payment
    from source
    where order_id is not null
      and payment_value::numeric >= 0
)

select * from renamed
