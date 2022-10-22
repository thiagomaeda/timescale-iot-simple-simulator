SELECT create_hypertable('dados_sensores','time');

CREATE INDEX ix_tag_time ON dados_sensores (tag_name, time DESC);

CREATE MATERIALIZED VIEW dados_consolidados_randomtag
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', "time") AS day,
  tag_name,
  max(tag_value) AS high,
  first(tag_value, time) AS open,
  last(tag_value, time) AS close,
  min(tag_value) AS low
FROM dados_sensores
GROUP BY day, tag_name;


O USO DA POLITICA ABAIXO SERIA OPCIONAL, POIS AUTOMATICAMENTE O TIMNE
SELECT add_continuous_aggregate_policy('dados_consolidados_randomtag',
  start_offset => INTERVAL '3 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 days');

SELECT add_compression_policy('dados_sensores', INTERVAL '1 day');



SELECT compress_chunk(i, if_not_compressed=>true)
  FROM show_chunks('dados_sensores', older_than => INTERVAL ' 1 minute') ;

SELECT pg_size_pretty(before_compression_total_bytes) as "Antes da Compressão",
  pg_size_pretty(after_compression_total_bytes) as "Depois da Compressão"
  FROM hypertable_compression_stats('dados_sensores');