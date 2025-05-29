/*
  Przykłady użycia funkcji rankingowych oraz LAG i LEAD
  na bazie bazy danych sklepu.
*/

/* 1. ROW_NUMBER() - numerowanie zamówień użytkownika wg daty */
SELECT
    id_order,
    id_user,
    number,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY id_user ORDER BY created_at) AS order_number_per_user
FROM [order]
ORDER BY id_user, created_at;


/* 2. RANK() - ranking produktów według ceny w każdej kategorii (z przerwami) */
SELECT
    id_product,
    name,
    id_category,
    price,
    RANK() OVER (PARTITION BY id_category ORDER BY price DESC) AS price_rank
FROM product
ORDER BY id_category, price_rank;


/* 3. DENSE_RANK() - ranking produktów wg ceny w każdej kategorii (bez przerw) */
SELECT
    id_product,
    name,
    id_category,
    price,
    DENSE_RANK() OVER (PARTITION BY id_category ORDER BY price DESC) AS dense_price_rank
FROM product
ORDER BY id_category, dense_price_rank;


/* 4. LAG() - poprzednia wartość ceny produktu w ramach kategorii (wg ceny malejąco) */
SELECT
    id_product,
    name,
    id_category,
    price,
    LAG(price) OVER (PARTITION BY id_category ORDER BY price DESC) AS previous_price
FROM product
ORDER BY id_category, price DESC;


/* 5. LEAD() - następna wartość ceny produktu w ramach kategorii (wg ceny malejąco) */
SELECT
    id_product,
    name,
    id_category,
    price,
    LEAD(price) OVER (PARTITION BY id_category ORDER BY price DESC) AS next_price
FROM product
ORDER BY id_category, price DESC;
