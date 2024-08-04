WITH for_update AS (
		SELECT today.account_rk
		, today.effective_date
		, prev_day.account_out_sum
	FROM rd.account_balance AS today
	LEFT JOIN rd.account_balance AS prev_day
		ON today.account_rk = prev_day.account_rk
		AND today.effective_date - INTERVAL '1 day' = prev_day.effective_date
	WHERE today.account_in_sum != prev_day.account_out_sum
)
	
UPDATE rd.account_balance AS tb
SET account_in_sum = cte.account_out_sum
FROM for_update AS cte
WHERE tb.account_rk = cte.account_rk
	AND tb.effective_date = cte.effective_date;
