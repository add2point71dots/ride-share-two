require_relative 'spec_helper'

describe "Trip tests" do
  let(:trip) { RideShare::Trip.new({ id: 2, driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 5 }) }
  let(:trips_array) { RideShare::Trip.all }
  let(:csv_info) { CSV.read('support/trips.csv')[1..-1] }

  describe "Trip#initialize" do
    it "Takes an ID, driver_id, rider_id, date, and rating" do
      trip.must_respond_to :id
      trip.id.must_equal 2

      trip.must_respond_to :driver_id
      trip.driver_id.must_equal 4

      trip.must_respond_to :rider_id
      trip.rider_id.must_equal 8

      trip.must_respond_to :date
      trip.date.must_equal Date.parse("2014-07-12")

      trip.must_respond_to :rating
      trip.rating.must_equal 5
    end

    it "Only accepts non-negative integer IDs for all ID fields" do
      trip_hash1 = { id: "id", driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 5 }
      trip_hash2 = { id: -2, driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 5 }

      proc { RideShare::Trip.new(trip_hash1) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash2) }.must_raise ArgumentError

      trip_hash3 = { id: 2, driver_id: 4.5, rider_id: 8, date: "2014-07-12", rating: 5 }
      trip_hash4 = { id: 2, driver_id: -4, rider_id: 8, date: "2014-07-12", rating: 5 }

      proc { RideShare::Trip.new(trip_hash3) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash4) }.must_raise ArgumentError

      trip_hash5 = { id: 2, driver_id: 4, rider_id: [8], date: "2014-07-12", rating: 5 }
      trip_hash6 = { id: 2, driver_id: 4, rider_id: -8, date: "2014-07-12", rating: 5 }

      proc { RideShare::Trip.new(trip_hash5) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash6) }.must_raise ArgumentError
    end

    it "Only accepts non-empty strings for Date" do
      trip_hash1 = { id: 2, driver_id: 4, rider_id: 8, date: 87, rating: 5 }
      trip_hash2 = { id: 2, driver_id: 4, rider_id: 8, date: "", rating: 5 }

      proc { RideShare::Trip.new(trip_hash1) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash2) }.must_raise ArgumentError
    end

    it "raises ArgumentError if the date string cannot be parsed to a Date" do
      trip_hash1 = { id: 2, driver_id: 4, rider_id: 8, date: "jsad;flk", rating: 5 }
      trip_hash2 = { id: 2, driver_id: 4, rider_id: 8, date: "Two weeks ago", rating: 5 }
      trip_hash3 = { id: 2, driver_id: 4, rider_id: 8, date: "a trip happened at some point", rating: 5 }

      proc { RideShare::Trip.new(trip_hash1) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash2) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash3) }.must_raise ArgumentError
    end

    it "Once initialized, date must be a Date" do
      trip.date.must_be_instance_of Date
    end

    it "Rating must be an integer 1-5" do
      trip_hash1 = { id: 2, driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 0 }
      trip_hash2 = { id: 2, driver_id: 4, rider_id: 8, date: "2014-07-12", rating: "rating!" }
      trip_hash3 = { id: 2, driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 6 }

      proc { RideShare::Trip.new(trip_hash1) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash2) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash3) }.must_raise ArgumentError
    end

    it "All fields are required" do
      trip_hash1 = { driver_id: 4, rider_id: 8, date: "2014-07-12", rating: 1 }
      trip_hash2 = { id: 2, rider_id: 8, date: "2014-07-12", rating: 1 }
      trip_hash3 = { id: 2, driver_id: 4, date: "2014-07-12", rating: 1 }
      trip_hash4 = { id: 2, driver_id: 4, rider_id: 8, rating: 1 }
      trip_hash5 = { id: 2, driver_id: 4, rider_id: 8, date: "2014-07-12" }

      proc { RideShare::Trip.new(trip_hash1) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash2) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash3) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash4) }.must_raise ArgumentError
      proc { RideShare::Trip.new(trip_hash5) }.must_raise ArgumentError
    end
  end

  describe "Trip.all" do
    it "Trip.all returns an array" do
      trips_array.must_be_instance_of Array
    end

    it "The first and last element of the array is a Trip" do
      trips_array[0].must_be_instance_of RideShare::Trip
      trips_array[-1].must_be_instance_of RideShare::Trip
    end

    it "The number of trips is correct" do
      trips_array.length.must_equal csv_info.count
    end

    it "The information for the first & last trip is correct" do
      trips_array[0].id.must_equal csv_info[0][0].to_i
      trips_array[0].driver_id.must_equal csv_info[0][1].to_i
      trips_array[0].rider_id.must_equal csv_info[0][2].to_i
      trips_array[0].date.must_equal Date.parse(csv_info[0][3])
      trips_array[0].rating.must_equal csv_info[0][4].to_i

      trips_array[-1].id.must_equal csv_info[-1][0].to_i
      trips_array[-1].driver_id.must_equal csv_info[-1][1].to_i
      trips_array[-1].rider_id.must_equal csv_info[-1][2].to_i
      trips_array[-1].date.must_equal Date.parse(csv_info[-1][3])
      trips_array[-1].rating.must_equal csv_info[-1][4].to_i
    end
  end

  describe "Trip.find_driver_trips" do
    it "Returns an Array" do
      RideShare::Trip.find_driver_trips(2).must_be_instance_of Array
    end

    it "The first and last element of the array is a Trip" do
      drivers_trips = RideShare::Trip.find_driver_trips(2)

      drivers_trips[0].must_be_instance_of RideShare::Trip
      drivers_trips[-1].must_be_instance_of RideShare::Trip
    end

    it "The number of trips is correct" do
      RideShare::Trip.find_driver_trips(2).length.must_equal 8
    end

    it "Returns empty array if no trips are found" do
      RideShare::Trip.find_driver_trips(10000).must_equal []
    end
  end

  describe "Trip.find_rider_trips" do
    it "Returns an Array" do
      RideShare::Trip.find_rider_trips(2).must_be_instance_of Array
    end

    it "The first and last element of the array is a Trip" do
      riders_trips = RideShare::Trip.find_rider_trips(2)

      riders_trips[0].must_be_instance_of RideShare::Trip
      riders_trips[-1].must_be_instance_of RideShare::Trip
    end

    it "The number of trips is correct" do
      RideShare::Trip.find_rider_trips(41).length.must_equal 3
    end

    it "Returns empty array if no trips are found" do
      RideShare::Trip.find_rider_trips(10000).must_equal []
    end
  end

  describe "Trip#driver" do
    it "Returns a Driver object if the driver exists" do
      trip.driver.must_be_instance_of RideShare::Driver
    end

    it "Returns the correct Driver for a driver that exists" do
      driver = trip.driver
      driver.name.must_equal "Jeromy O'Keefe DVM"
    end

    it "Outputs message and returns nil if driver doesn't exist" do
      bad_trip = RideShare::Trip.new({ id: 2, driver_id: 0, rider_id: 8, date: "2014-07-12", rating: 5 })

      proc { bad_trip.driver }.must_output (/.+/)
      bad_trip.driver.must_equal nil
    end
  end

  describe "Trip#rider" do
    it "Returns a Rider object if the rider exists" do
      trip.rider.must_be_instance_of RideShare::Rider
    end

    it "Returns the correct Rider for a rider that exists" do
      rider = trip.rider
      rider.phone.must_equal "1-904-093-5211 x9183"
    end

    it "Outputs message and returns nil if rider doesn't exist" do
      bad_trip = RideShare::Trip.new({ id: 2, driver_id: 4, rider_id: 0, date: "2014-07-12", rating: 5 })

      proc { bad_trip.rider }.must_output (/.+/)
      bad_trip.rider.must_equal nil
    end
  end
end
