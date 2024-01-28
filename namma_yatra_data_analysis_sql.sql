select * from trips;

select count(*) from trips_details;

select * from loc;

select * from duration;

select * from payment;
sp_rename 'trips_details4', 'trips_details'

-- total trips --
select count(distinct tripid) from trips_details;

--check if there are duplicates present in tripid --
select tripid, count(tripid) as cnt from trips_details
group by tripid
having count(tripid) >1

--what are total number of drivers --
select count(distinct driverid) as total_drivers from trips;

--total earnings
select * from trips;
select sum(fare) as earnings from trips;

--total completed trips
select count(distinct tripid) as completed_trips from trips;

--total searches
select sum(searches) as total_searches from trips_details;

--total searches which got estimated
select sum(searches_got_estimate) as estimated_searches from trips_details;

--total searches which got quotes
select sum(searches_got_quotes) as quoted_searches from trips_details;

--total driver cancelled
select * from trips_details;
select count(*) - sum(driver_not_cancelled) as total_drivers_cancelled from trips_details;

--total otp entered
select sum(otp_entered) as total_otp_entered from trips_details;

--total  end ride
select sum(end_ride) as total_end_ride from trips_details;

select * from trips;

--what is average distance per trip
select avg(distance) as avg_distance from trips;

--what is average fare per trip
select avg(fare) as avg_fare from trips;

--what is the distance travelled
select sum(distance) as total_distance from trips;

--which is the most preferred payment method
select * from trips;
select * from payment;
with trip_payment_method as (
select a.*, b.method from trips a inner join payment b
on a.faremethod = b.id )
select top 1 method, count(distinct tripid) as total_count_payment_used from trip_payment_method
group by method
order by total_count_payment_used desc;

--the highest payment made through which instrument
select a.method from payment a inner join 
(select top 1 * from trips
order by fare desc) b
on a.id=b.faremethod;

--other way of solving the problem
select a.method from payment a inner join 
(select top 1 faremethod, sum(fare) as fare from trips
group by faremethod
order by sum(fare) desc) b
on a.id=b.faremethod

--which two locations had the most trips
select b.* from
(select a.*,dense_rank() over(order by total_trips desc) as rnk 
from
(select loc_from, loc_to, count(distinct tripid) as total_trips 
from trips
group by loc_from,loc_to) as a) as b
where rnk=1;

--top 5 earning drivers
select * from trips;

select b.* from
(select a.*,dense_rank() over(order by total_earnings desc) as rnk
from
(select driverid, sum(fare) as total_earnings from trips 
group by driverid) as a) as b
where b.rnk <=5;

--which duration had more trips

select * from (select a.*, dense_rank() over(order by cnt desc) as rnk from
(select duration, count(distinct tripid) as cnt from trips
group by duration) as a) as b
where b.rnk=1;

-- which driver , customer had most trips together
select b.* from 
(select a.*, dense_rank() over (order by cnt desc) as rnk from
(select driverid,custid,count(distinct tripid) as cnt from trips
group by driverid,custid) as a) as b
where b.rnk=1;

-------------

select * from trips_details;

--search to estimate rate
select sum(searches_got_estimate) * 100.0 /sum(searches) as search_to_estimate_rate
from trips_details;

--estimate to search for quote rates
select sum(searches_for_quotes) * 100.0/sum(searches_got_estimate)
from trips_details;

--quote acceptance rate
select sum(customer_not_cancelled) * 100.0/ sum(searches_got_quotes)
from trips_details;

--trips cancelled rate by driver
select (count(*) - sum(driver_not_cancelled)) * 100.0/ sum(searches_got_quotes)
from trips_details;

--trips completed after searches (trips completion rate)
select sum(end_ride) * 100.0/sum(searches) 
from trips_details;

--find the area with highest trips in each duration
select b.* from
(select a.*, rank() over(partition by duration order by cnt desc) as rnk
from
(select duration, loc_from,count(distinct tripid) as cnt from trips
group by duration,loc_from) as a) as b
where b.rnk=1;

--which area got highest fares, trips, cancellation

--area producing highest fares
select * from 
(select a.*, rank() over(order by total_fare desc) as rnk 
from 
(select loc_from, sum(fare) as total_fare from trips
group by loc_from) as a) as c
where c.rnk=1;

--area giving highest driver cancellations
select * from 
(select a.*, rank() over(order by cnt desc) as rnk 
from 
(select loc_from, count(*) - sum(driver_not_cancelled) as cnt
from trips_details
group by loc_from) as a) as c
where c.rnk=1;

--area giving highest customer cancellations
select * from 
(select a.*, rank() over(order by cnt desc) as rnk 
from 
(select loc_from, count(*) - sum(customer_not_cancelled) as cnt
from trips_details
group by loc_from) as a) as c
where c.rnk=1;

--which duration got the highest trips and fares

--duration with the highest fares
select * from 
(select a.*, rank() over(order by total_fare desc) as rnk 
from 
(select duration, sum(fare) as total_fare from trips
group by duration) as a) as c
where c.rnk=1;

--duration with highest trips
select * from 
(select a.*, rank() over(order by cnt desc) as rnk 
from 
(select duration, count(distinct tripid) as cnt from trips
group by duration) as a) as c
where c.rnk=1;
