//
//  UserDefaultsManager.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 10.02.2023.
//

import Foundation

class UserDefaultsManager {
    
    private let dataKey = "data"
    
    lazy var someData: Data = {
        
        var someData = Data()
        
        do {
            let resultData = Result(categories: [""], created_at: "", id: "", value: "")
            
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(resultData)
            someData = data
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
        
        return someData
    }()
    
        private init() {
            UserDefaults.standard.register(defaults: [
                dataKey : someData
            ])
        }
    
    
    static var shared = UserDefaultsManager()
    
    
    func getData() -> [Result]? {
        var result = [Result(categories: [""], created_at: "", id: "", value: "")] // cтворюю масив з одним жартом який потім просто заміниться масивом збережених жартів
        if let data = UserDefaults.standard.data(forKey: dataKey) { // дістаю Data
            do {
                let decoder = JSONDecoder()

                let decodeData = try decoder.decode([Result].self, from: data) // декодю в масив жартів
                
                result = decodeData // заміняю тимчасовий масив на масив збережених
            } catch {
                print("Unable to Decode Data (\(error))")
            }
        }
        return result // і повертаю його
    }
    
    func setData(dataToSave: Result) {
      
        var arrayDataToSave = [dataToSave] // тут поточний жарт масивом в якому один жарт

        if let data = UserDefaults.standard.data(forKey: dataKey) { // тут витягую збережену дату
            
            do {
                let decoder = JSONDecoder()

                let decodeData = try decoder.decode([Result].self, from: data) // тут декодю в масив жартів
               
                arrayDataToSave += decodeData // тут зліплюю в один масив в якому на першому місці новий жарт

                decodeData.forEach { element in // тут превіряю чи в старому масиві немає жарту який хочу зберегти
                    if element.id == dataToSave.id {
                        arrayDataToSave.removeFirst() // якщо є то він на першому місці і тут він видаляється
                    }                                 // (тільки ця перевірка вже зайва я це перевіряю в іншому місці)
                 }
                
            } catch {
                print("Unable to Decode Data (\(error))")
            }
            
        }

        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(arrayDataToSave) // тут конвертую назад в Data

            UserDefaults.standard.set(data, forKey: dataKey) // і зберігаю

        } catch {
            print("Unable to Encode Array of Data (\(error))")
        }

    }
    
    func removeFromData(data: Result) {
        var count = 0
        var savedData = UserDefaultsManager.shared.getData()
        savedData?.forEach({ item in
           
            if item.id == data.id {
                savedData?.remove(at: count)
            }
            
            count += 1
            
        })
        
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(savedData)

            UserDefaults.standard.set(data, forKey: dataKey)
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
}
