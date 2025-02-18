CREATE DATABASE HotelManagement;
USE HotelManagement;
ALTER TABLE Rooms ADD PRIMARY KEY(RoomID);
ALTER TABLE Guests MODIFY GuestID VARCHAR(10) NOT NULL;
ALTER TABLE Guests ADD PRIMARY KEY(GuestID);
SELECT * FROM Rooms;
SELECT * FROM Guests;
ALTER TABLE Bookings MODIFY BookingID VARCHAR(10);
ALTER TABLE Bookings ADD PRIMARY KEY(BookingID);
ALTER TABLE Bookings MODIFY GUESTID VARCHAR(10);
ALTER TABLE Bookings ADD FOREIGN KEY(GuestID) REFERENCES Guests(GuestID);
ALTER TABLE Bookings ADD FOREIGN KEY(RoomID) REFERENCES Rooms(RoomID);
ALTER TABLE Bookings ADD TempCID Date;
UPDATE Bookings SET TempCID = STR_TO_DATE(CheckIn_date, '%d-%m-%Y');
ALTER TABLE Bookings DROP CheckIN_date;
ALTER TABLE Bookings CHANGE COLUMN TempCID CheckInDate DATE;
ALTER TABLE Bookings ADD TempCOD Date;
UPDATE Bookings SET TempCOD = STR_TO_DATE(CheckOut_date, '%d-%m-%Y');
ALTER TABLE Bookings DROP CheckOut_date;
ALTER TABLE Bookings CHANGE COLUMN TempCOD CheckOutDate DATE;
SELECT * FROM Bookings;
ALTER TABLE Services Modify ServiceID VARCHAR(10);
ALTER TABLE Services ADD PRIMARY KEY(ServiceID);
ALTER TABLE Services Modify BookingID VARCHAR(10);
ALTER TABLE Services ADD FOREIGN KEY(BookingID) REFERENCES Bookings(BookingID);
SELECT * FROM Services;
ALTER TABLE Staff MODIFY StaffID VARCHAR(10);
ALTER TABLE Staff ADD PRIMARY KEY(StaffID);
ALTER TABLE Staff MODIFY Email VARCHAR(30);
SELECT * FROM Staff;
# JOIN Guests, Bookings, Services
SELECT Guests.GuestID, Guests.Name, Bookings.BookingID, Bookings.RoomID,Bookings.CheckINDate, Bookings.CheckOutDate, 
Bookings.Price, Bookings.Status, Services.ServiceID, Services.Service,Services.Price AS ServicePrice
FROM Guests INNER JOIN Bookings ON Guests.GuestID=Bookings.GuestID LEFT JOIN Services 
ON Bookings.BookingID=Services.BookingID ORDER BY Guests.GuestID, Bookings.BookingID, Services.ServiceID;
#Occupancy Rate
SELECT COUNT(RoomID) AS TotalBookedRooms, COUNT(CASE WHEN Status='Confirmed' THEN RoomID END) AS 
OccupiedRooms, ROUND((COUNT(CASE WHEN Status='Confirmed' THEN RoomID END))*100 / COUNT(RoomID), 2) 
AS OccupancyRate FROM Bookings;
#Revenue from Bookings ->deduct 30% from cancelled
SELECT SUM(Price) AS ConfirmedPrice FROM Bookings WHERE Status='Confirmed';
SELECT SUM(Price*0.3) AS CancelledPrice FROM Bookings WHERE Status='Cancelled';
SELECT SUM(CASE WHEN Status='Confirmed' THEN Price
WHEN Status='Cancelled' THEN Price * 0.3 Else 0 END) AS BookingRevenue FROM Bookings;
SELECT SUM(Price)AS ServiceRevenue FROM Services;
SELECT( SELECT SUM(CASE WHEN Status='Confirmed' THEN Price
WHEN Status='Cancelled' THEN Price * 0.3 Else 0 END) FROM Bookings) AS BookingRevenue, 
(SELECT SUM(Price) FROM Services) AS ServiceRevenue,((SELECT SUM(CASE WHEN Status='Confirmed' THEN Price
WHEN Status='Cancelled' THEN Price * 0.3 Else 0 END) FROM Bookings) + (SELECT SUM(Price) FROM Services)) 
AS TotalRevenue;
#Guest details with Booking information
SELECT Guests.GuestID,Guests.Name,Guests.Email,Guests.MobileNumber,Bookings.BookingID,Bookings.RoomID AS 
RoomNumber,Bookings.Status,Bookings.CheckInDate,Bookings.CheckOutDate FROM Guests INNER JOIN Bookings ON
Guests.GuestID=Bookings.GuestID;
# Display all the services availed by the Guests
SELECT Guests.GuestID,Guests.Name,Services.ServiceID,Services.Service,Services.Price AS ServicePrice
FROM Guests INNER JOIN Bookings 
ON Guests.GuestID=Bookings.GuestID 
INNER JOIN Services ON Bookings.BookingID=Services.BookingID ORDER BY Guests.GuestID;
#Calculate Cancelled Bookings and Confirmed Bookings
SELECT Status, COUNT(BookingID) AS BookingCount FROM Bookings GROUP BY Status;
#total service cost availed by each service type
SELECT Service, SUM(Price) AS ServicePrice FROM Services GROUP BY Service;
#Display Prices of Rooms in descending Order
SELECT DISTINCT(RoomType), Price 
 FROM Rooms ORDER BY Price DESC;
 # Queries demonstrating data filtering (WHERE, HAVING).
 SELECT ServiceID, Service,Price FROM Services where Price>500;
 SELECT * FROM Bookings;
 SELECT BookingID, GuestID,RoomID,CheckInDate,CheckOutDate FROM Bookings WHERE CheckInDate BETWEEN '2024-01-01' AND '2024-08-01';
 SELECT * FROM Staff where Name LIKE '%A';
 SELECT 
    g.Name AS GuestName, 
    g.GuestID, 
    (SELECT 
        SUM(
            CASE 
                WHEN b.Status = 'Confirmed' THEN b.Price
                WHEN b.Status = 'Cancelled' THEN b.Price * 0.3
                ELSE 0
            END
        )
     FROM Bookings b 
     WHERE b.GuestID = g.GuestID
    ) + 
    (SELECT 
        SUM(s.Price) 
     FROM Services s 
     WHERE s.BookingID IN 
        (SELECT b.BookingID FROM Bookings b WHERE b.GuestID = g.GuestID)
    ) AS TotalSpent
FROM 
    Guests g
ORDER BY 
    TotalSpent DESC
LIMIT 5;
SELECT 
    g.Name AS GuestName, 
    g.GuestID, 
    (SELECT COUNT(*) 
     FROM Services s 
     WHERE s.BookingID IN 
        (SELECT b.BookingID FROM Bookings b WHERE b.GuestID = g.GuestID)
    ) AS TotalServices
FROM 
    Guests g
ORDER BY 
    TotalServices DESC
LIMIT 1;

