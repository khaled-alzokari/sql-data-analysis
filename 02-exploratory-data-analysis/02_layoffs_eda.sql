-- =====================================================
-- المشروع الثاني: التحليل الاستكشافي للبيانات (EDA)
-- الداتا: layoffs_staging2 (بعد ما خلصنا التنظيف بالمشروع الأول)
-- الهدف: نفهم الداتا ونطلع أنماط واستنتاجات، مو بس نعرض أرقام
-- =====================================================


-- المرحلة الأولى: نظرة عامة على الداتا
-- 1.1 نقوم بمعاينة الجدول يشكل كامل
select *
from layoffs_staging2;

-- 1.2 أكبر عدد تسريح بيوم واحد، وأعلى نسبة تسريح
-- ملاحظة(نسبة1يعني الشكرة سرحت كل الموظفين يعني افلست)
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- 1.3 الشركات اللي سرّحت كل موظفينها، مرتبة حسب التمويل اللي جمعته
-- بتعطينا فكرة: حتى الشركات اللي جمعت مليارات أغلقت
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;


-- المرحلة الثانية: التجميع حسب الأبعاد (group by)
-- 2.1 مجموع التسريح لكل شركة
select company, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company
order by 2 desc;

-- 2.2 المدى الزمني للداتا (من أول تاريخ لآخر تاريخ)
select min(`date`), max(`date`)
from layoffs_staging2;

-- 2.3 مجموع التسريح لكل قطاع (industry)
select industry, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by industry
order by 2 desc;

-- 2.4 مجموع التسريح لكل دولة
select country, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by country
order by 2 desc;

-- 2.5 مجموع التسريح لكل سنة
select year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- 2.6 مجموع التسريح لكل مرحلة تمويل (stage)
select stage, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by stage
order by 2 desc;


-- المرحلة الثالثة: التحليل عبر الزمن (Rolling Total)
-- 3.1 مجموع التسريح لكل شهر
-- substring(`date`, 1, 7) بتجيب السنة والشهر بس، مثال: 2023-01
select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc;

-- 3.2 المجموع التراكمي (Rolling Total)
-- بنحط الاستعلام السابق بـ CTE وبعدين بنجمع تراكمياً بـ window function
with rolling_total as
(
    select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as total_off
    from layoffs_staging2
    where substring(`date`, 1, 7) is not null
    group by `month`
    order by 1 asc
)
select `month`,
       total_off,
       sum(total_off) over (order by `month`) as rolling_total
from rolling_total;



-- المرحلة الرابعة: ترتيب الشركات لكل سنة (Ranking)
-- 4.1 مجموع التسريح لكل شركة لكل سنة
select company, year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- 4.2 أعلى 5 شركات تسريحاً بكل سنة
-- CTE أول: نجمع لكل شركة وسنة
-- CTE تاني: نرتّب الشركات داخل كل سنة بـ dense_rank
-- النتيجة النهائية: نفلتر على الترتيب <= 5
with company_year (company, years, total_laid_off) as
(
    select company, year(`date`), sum(total_laid_off)
    from layoffs_staging2
    group by company, year(`date`)
),
company_year_rank as
(
    select *,
           dense_rank() over (partition by years order by total_laid_off desc) as ranking
    from company_year
    where years is not null
)
select *
from company_year_rank
where ranking <= 5;

