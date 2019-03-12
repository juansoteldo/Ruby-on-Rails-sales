class GenerateRequestTokens < ActiveRecord::Migration[5.2]
  def up

    # https://stackoverflow.com/a/12590064/1888458
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"
    execute <<SQL
      DROP FUNCTION IF EXISTS stringify_bigint(bigint);
      CREATE FUNCTION stringify_bigint(n bigint) RETURNS text
          LANGUAGE plpgsql IMMUTABLE STRICT AS $$
      DECLARE
       alphabet text:='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
       base int:=length(alphabet); 
       _n bigint:=abs(n);
       output text:='';
      BEGIN
       LOOP
         output := output || substr(alphabet, 1+(_n%base)::int, 1);
         _n := _n / base; 
         EXIT WHEN _n=0;
       END LOOP;
       RETURN output;
      END $$
SQL

    # http://wiki.postgresql.org/wiki/Pseudo_encrypt
    execute <<SQL
      DROP FUNCTION IF EXISTS pseudo_encrypt(bigint);
      CREATE FUNCTION pseudo_encrypt(VALUE bigint) returns bigint AS $$
      DECLARE
        l1 bigint;
        l2 bigint;
        r1 bigint;
        r2 bigint;
      i int:=0;
      BEGIN
          l1:= (VALUE >> 32) & 4294967295::bigint;
          r1:= VALUE & 4294967295;
          WHILE i < 3 LOOP
              l2 := r1;
              r2 := l1 # ((((1366.0 * r1 + 150889) % 714025) / 714025.0) * 32767*32767)::int;
              l1 := l2;
              r1 := r2;
              i := i + 1;
          END LOOP;
      RETURN ((l1::bigint << 32) + r1);
      END;
      $$ LANGUAGE plpgsql strict immutable;
SQL

    execute <<SQL
      UPDATE requests r
          SET token = r2.hash
          FROM (SELECT r2.*, stringify_bigint(pseudo_encrypt(row_number() over ())) as hash
                FROM requests r2
               ) r2
          WHERE r2.id = r.id;
SQL
    add_index :requests, :token, unique: true
  end

  def down
    remove_index :requests, :token
  end
end
