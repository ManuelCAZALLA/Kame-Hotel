import Foundation

struct Client {
    let name: String
    let age: Int
    let height: Int
    
}
struct Reservation {
    var id: Int
    let nameHotel: String
    var clientList:  [Client]
    let duration: Int
    let price: Double
    var breakfast: Bool
}
enum ReservationError: Error {
    case duplicateId
    case duplicateClient
    case reservationNotFound
}

class HotelReservationManager {
   private var reservations: [Reservation]
   var idCounter: Int
    
    init() {
        reservations = []
        idCounter = 1
    }
    func addReservations(clientsList: [Client], duration: Int, breakfast: Bool) throws -> Reservation {
        // Verifico si hay una reserva con el mismo id
        for reservation in reservations {
            if reservation.id == idCounter {
                throw ReservationError.duplicateId
            }
        }
        // Verifico si un cliente ya tiene reserva
        for client in clientsList {
            for reservation in reservations {
                if reservation.clientList.contains(where: {$0.name == client.name}) {
                    throw ReservationError.duplicateClient
                }
            }
        }
        let priceBase: Double = 20.0
        let priceBreakfast : Double = breakfast ? 1.25 : 1
        let totalPrice = Double(clientsList.count) * priceBase * Double(duration) * priceBreakfast
        // Creo reserva
        
        let reservation = Reservation(id: idCounter,
                                      nameHotel: "kame Hotel",
                                      clientList: clientsList,
                                      duration: duration,
                                      price: totalPrice
                                      , breakfast: breakfast)
        reservations.append(reservation)
        idCounter += 1
        
        return reservation
        
    }
    
    func cancelReservation(id: Int) throws {
      guard let deleteReservation = reservations.firstIndex(where: {$0.id == id}) else {
          throw ReservationError.reservationNotFound
        
        }
        reservations.remove(at: deleteReservation)
    }
    
    func allReservation() -> [Reservation] {
        return reservations
    }
}


func testAddReservation() {
    let hotel = HotelReservationManager()
    
    let client1 = Client(name: "Goku", age: 30, height: 175)
    let client2 = Client(name: "Bulma", age: 35, height: 180)
   
    
    do {
        let reservation = try hotel.addReservations(clientsList: [client1], duration: 3, breakfast: true)
        assert(hotel.allReservation().count == 1)
        assert(hotel.allReservation()[0].id == 1)
        
    } catch {
        assertionFailure("Error al registrar la reserva")
    }
    // Verificar ID duplicado
    do {
        let reservation = try hotel.addReservations(clientsList: [client2], duration: 3, breakfast: true)
        assert(hotel.allReservation()[1].id == 2)
        
    } catch {
        
        let validationError = error as? ReservationError
        assert(validationError == ReservationError.duplicateId)
    }
    // Verificar cliente duplicado
    
    do {
        let duplicateReservation = try hotel.addReservations(clientsList: [client1], duration: 2, breakfast: false)
        assert(hotel.allReservation().count == 1)
    } catch  {
        let checkError = error as? ReservationError
        assert(checkError == ReservationError.duplicateClient)
        
    }
}

func testCancelReservation() {
    
    let director = HotelReservationManager()
    
    let goku = Client(name: "Goku", age: 30, height: 175)
    
    // Añadir reserva
    do {
        let _ = try director.addReservations(clientsList: [goku], duration: 3, breakfast: true)
    } catch {
        assertionFailure("No  espero ningún error al añadir la reserva")
    }
    
    // Cancelar reserva existente
    do {
        try director.cancelReservation(id: 1)
        assert(director.allReservation().count == 0)
    } catch {
        assertionFailure("No espero ningún error al cancelar la reserva")
    }
    
    // Cancelar reserva no existente
    do {
        try director.cancelReservation(id: 1)
        assert(director.allReservation().count == 0)
        assertionFailure("No hay reservas")
        
    } catch  {
        let validateError = error as? ReservationError
        assert(validateError == ReservationError.reservationNotFound)
       }
}
func testReservationPrice() {
    let hotelManager = HotelReservationManager()
    
    let client1 = Client(name: "Freezer", age: 30, height: 185)
    let client2 = Client(name: "Beerus", age: 30, height: 185)
    
    
    do {
        let reserva1 = try hotelManager.addReservations(clientsList: [client1], duration: 2, breakfast: true)
    } catch {
        assertionFailure("No espero ningún error")
    }
    
    
    do {
        let reserva2 = try hotelManager.addReservations(clientsList: [client2], duration: 2, breakfast: true)
    } catch {
        assertionFailure("No espero ningún error al añadir la segunda reserva")
    }
    
    let reservations = hotelManager.allReservation()
    assert(reservations.count == 2)
    assert(reservations[0].price == reservations[1].price)
}

testAddReservation()
testCancelReservation()
testReservationPrice()




