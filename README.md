### Likes

Есть таблица likes (user_id: integer, post_id: integer, created_at: datetime, updated_at: datetime)
В этой таблице порядка нескольких миллионов записей.
Сервер делает несколько разных запросов по этой таблице, время выполнения этих запросов > 1 sec.
Запросы:
```sql
  SELECT COUNT(*) FROM likes WHERE user_id = ?
  SELECT COUNT(*) FROM likes WHERE post_id = ?
  SELECT * FROM likes WHERE user_id = ? AND post_id = ?
```
Как узнать почему тормозят запросы, как их можно ускорить (все возможные варианты).

#### Ответ
В моей таблице Like 2492280 записей.
Время выполнения запросов соответственно: 180ms, 190ms, 190ms
Далее опишу план действии по определению причины медленного выполнения запросов:
1. Посмотреть план запроса с помощью EXPLAIN
```ruby
  Like.select("COUNT(*)").where(user_id: 5).explain
```
выведет такой результат:
```sql
=> EXPLAIN for: SELECT COUNT(*) FROM "likes" WHERE "likes"."user_id" = $1 [["user_id", 5]]
                                     QUERY PLAN
-------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=34749.89..34749.90 rows=1 width=8)
   ->  Gather  (cost=34749.67..34749.88 rows=2 width=8)
         Workers Planned: 2
         ->  Partial Aggregate  (cost=33749.67..33749.68 rows=1 width=8)
               ->  Parallel Seq Scan on likes  (cost=0.00..33749.62 rows=19 width=0)
                     Filter: (user_id = '5'::bigint)
```
Видим, что большая часть результирующей стоимости запроса заложена в первой операции - последовательном чтении Seq Scan.
Тогда как наиболее выигрышным для чтения небольшой выборки (user_id: 5) был бы Index Scan.
После добавления индекса:
```sql
=> EXPLAIN for: SELECT COUNT(*) FROM "likes" WHERE "likes"."user_id" = $1 [["user_id", 5]]
                                            QUERY PLAN
--------------------------------------------------------------------------------------------------
 Aggregate  (cost=106.17..106.18 rows=1 width=8)
   ->  Index Only Scan using index_likes_on_user_id on likes  (cost=0.43..106.06 rows=45 width=0)
         Index Cond: (user_id = '5'::bigint)
```
Видим, что стоимость результирующей операции упала до 106.18
Время выполнения запроса снизилось до 2ms

2. Добавить counter_cache
После добавления
```ruby
belongs_to :user, counter_cache: true
```
такой код
```ruby
User.select("likes_count").where(id: 5).explain
```
покажет следующий план запроса:
```sql
=> EXPLAIN for: SELECT "users"."likes_count" FROM "users" WHERE "users"."id" = $1 [["id", 5]]
                               QUERY PLAN
------------------------------------------------------------------------
 Index Scan using users_pkey on users  (cost=0.29..8.31 rows=1 width=4)
   Index Cond: (id = '5'::bigint)
```
Таким образом мы избавились от операции (Aggregate) и уменьшили стоимость запроса
Время выполнения запроса сократилось до 0.5ms

3. Проверить наличие блокировок
4. Проверить нет ли проблем на уровне оборудовния (сеть, диски)

### Pending Posts
Есть такой запрос:
```sql
  SELECT * from pending_posts 
    WHERE user_id <> ?
      AND NOT approved
      AND NOT banned
      AND pending_posts.id NOT IN(
        SELECT pending_post_id FROM viewed_posts
          WHERE user_id = ?)
```
Какие индексы надо создать и как изменить запрос (если требуется) чтобы запрос работал максимально быстро. 