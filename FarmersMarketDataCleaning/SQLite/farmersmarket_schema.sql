CREATE TABLE farmersmarket
  ( 
    FMID       INT PRIMARY KEY, 
	MarketName	TEXT,
	Website	TEXT,
	Facebook	TEXT,
	Twitter	TEXT,
	Youtube	TEXT,
	OtherMedia	TEXT,
	street	TEXT,
	city	TEXT,
	County	TEXT,
	State	TEXT,
	zip	INTEGER,
	Season1DateStart	NUMERIC,
	Season1DateEnd	NUMERIC,
	Season1Time	NUMERIC,
	Season2DateStart	NUMERIC,
	Season2DateEnd	NUMERIC,
	Season2Time	NUMERIC,
	Season3DateStart	NUMERIC,
	Season3DateEnd	NUMERIC,
	Season3Time	NUMERIC,
	Season4DateStart	NUMERIC,
	Season4DateEnd	NUMERIC,
	Season4Time	NUMERIC,
	x	REAL,
	y	REAL,
	Location	TEXT,
	Credit	CHAR(1),
	WIC	CHAR(1),
	WICcash	CHAR(1),
	SFMNP	CHAR(1),
	SNAP	CHAR(1),
	Organic	CHAR(1),
	Bakedgoods	CHAR(1),
	Cheese	CHAR(1),
	Crafts	CHAR(1),
	Flowers	CHAR(1),
	Eggs	CHAR(1),
	Seafood	CHAR(1),
	Herbs	CHAR(1),
	Vegetables	CHAR(1),
	Honey	CHAR(1),
	Jams	CHAR(1),
	Maple	CHAR(1),
	Meat	CHAR(1),
	Nursery	CHAR(1),
	Nuts	CHAR(1),
	Plants	CHAR(1),
	Poultry	CHAR(1),
	Prepared	CHAR(1),
	Soap	CHAR(1),
	Trees	CHAR(1),
	Wine	CHAR(1),
	Coffee	CHAR(1),
	Beans	CHAR(1),
	Fruits	CHAR(1),
	Grains	CHAR(1),
	Juices	CHAR(1),
	Mushrooms	CHAR(1),
	PetFood	CHAR(1),
	Tofu	CHAR(1),
	WildHarvested	CHAR(1),
	updateTime	NUMERIC
	ZipcodeCalc	NUMERIC 
  ); 