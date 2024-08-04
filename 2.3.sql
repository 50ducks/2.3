CREATE OR REPLACE PROCEDURE dm.update_account_balance_turnover()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time TIMESTAMP;
	end_time TIMESTAMP;
	rows_affected BIGINT;
BEGIN
	start_time := clock_timestamp();

	DROP VIEW IF EXISTS only_updated_data;
	CREATE TEMP VIEW only_updated_data AS
	WITH actp AS (
		SELECT a.account_rk,
			COALESCE(dc.currency_name, '-1'::TEXT) AS currency_name,
			a.department_rk,
			ab.effective_date,
			ab.account_in_sum,
			ab.account_out_sum
		FROM rd.account a
		LEFT JOIN rd.account_balance ab ON a.account_rk = ab.account_rk
		LEFT JOIN dm.dict_currency dc ON a.currency_cd = dc.currency_cd
	)
	SELECT a.account_rk
		,a.effective_date
		,a.account_in_sum
	FROM actp AS a
	LEFT JOIN dm.account_balance_turnover AS t
		ON a.account_rk = t.account_rk 
		AND a.effective_date = t.effective_date
	WHERE a.account_in_sum != t.account_in_sum;

	rows_affected := (
		SELECT COUNT(*)
		FROM only_updated_data
	);

	UPDATE dm.account_balance_turnover AS ot
	SET account_in_sum = u.account_in_sum
	FROM only_updated_data AS u
	WHERE ot.account_rk = u.account_rk
		AND ot.effective_date = u.effective_date;

	DROP VIEW only_updated_data;

	end_time := clock_timestamp();

	CALL logs.proc_logs(
		'dm.update_account_balance_turnover'
		, start_time
		, end_time
		, rows_affected
	);
END;
$$;