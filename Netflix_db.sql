-- Create table netflix

drop table if exists netflix;

create table netflix(
	show_id varchar(8),
	type varchar(10),
	title varchar(150),
	director varchar(250),
	casts varchar(1000),
	country varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
)

-- To verify if all the data is imported
select count(*) from netflix;

-- To find out different types
select distinct type
	from netflix;


-- 15 business problems

-- 1 - Total count of different types (Movies/TV shows)
select type, count(*) as total_count
from netflix
group by type;


-- 2 - Find the most common rating for Movies and TV shows
select type, rating
	from
(
select type, rating, count(*),
rank() over(partition by type order by count(*) desc)
from netflix
group by 1, 2
) as t1
where rank = 1;


-- 3 - List all movies released in a year(eg . 2020)

select title
from netflix
where type = 'Movie'
and release_year = 2020;

-- 4- Find the top 5 countries with the most content on netflix
select 
unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from netflix 
group by 1
	order by 2 desc
	limit 5;

-- 5 - Identify the longest movie
select * from netflix
where 
type = 'Movie'
and 
duration = (select max(duration) from netflix);


-- 6 - Find content added in the last 5 years
select *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'


-- 7 - Find all movies/ TV shows directed by 'Rajiv Chilaka'
select * from netflix
where director ilike '%Rajiv Chilaka%';


-- 8 - List all TV shows with more than 5 seasons
select * from netflix
where type = 'TV Show'
and 
split_part(duration,' ',1)::numeric > 5;

-- 9 - count the number of content items in each genre
select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_content
from netflix
group by 1
	order by 2 desc;


-- 10 - Find each year and avg content released by india on netflix. Return top 5 years with highest content
select 
extract(year from to_date(date_added, 'Month DD, YYYY')) as year,
count(*) as yearly_content,
round(
	count(*)::numeric / (select count(*) from netflix where country = 'India')::numeric * 100,2
) as avg_content_per_year
from netflix
	where country = 'India'
	group by 1
	order by 3 desc;

-- 11 - List all movies that are Documentaries
select * from netflix;

select * from
(
select *, unnest(string_to_array(listed_in,',')) as genre
from netflix
where type = 'Movie'
) as t1
where genre = 'Documentaries';

-- or it can also be done as
select *
from netflix
where listed_in ilike '%Documentaries%'


-- 12 - Find all content without a director
select *
from netflix
where director is null;

-- 13 - Find all the movies actor 'Salman khan' appeared in last 11 years;
select * from netflix
where casts ilike '%Salman Khan%'
and release_year > extract(year from current_date)-11


-- 14 - Find the top 10 actors who have appeared in the highest number of moie sproduced in india
select
unnest(string_to_array(casts,',')) as actors,
count(*) as total_contents
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
	limit 10;


-- 15 - Categorize the content based on he presence of the keywords 'kill' and 'violence' in the descriprion field.
-- Label content containing this keywords as bad and all other as good.
-- count the labels too.

with new_table as(
	select *,
	case
	when
	description ilike '%kill%'
	or
	description ilike '%violence%'
	then 'Bad_content'
	else 'Good_content'
	end category
	from netflix
)
select category, count(*) as total_content
from new_table
group by 1;