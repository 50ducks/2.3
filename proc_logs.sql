CREATE OR REPLACE PROCEDURE logs.proc_logs(
	procedure_name TEXT
	, start_time TIMESTAMP
	, end_time TIMESTAMP
	, rows_affected BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO logs.procedure_logs (
		procedure_name
		, start_time
		, end_time
		, rows_affected
	) VALUES (
		procedure_name
		, start_time
		, end_time
		, rows_affected
	);
END;
$$;