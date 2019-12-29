//
//  TableViewController.swift
//  Recipe App
//
//  Created by Cognizant on 12/28/19.
//  Copyright © 2019 PWH. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController,XMLParserDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //recipe model
    struct Recipe {
        var title: String
        var type: String
        //var ingredients: [String]
        //var steps: [String]
        //var image: UIImage
    }
    
    //local variables
    var recipes: [Recipe] = []
    var elementName: String = String()
    var recipeTitle = String()
    var recipeType = String()
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //load xml file
        if let path = Bundle.main.url(forResource: "recipe", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = (self as XMLParserDelegate)
                parser.parse()
                
            }
        }
        
        //init and populate picker
        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["Beverage", "Dessert"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title
        cell.detailTextLabel?.text = recipe.type
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        recipeTitle = (currentCell.textLabel?.text)!
        performSegue(withIdentifier: "detailSegue", sender: self)
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "detailSegue") {
            // initialize new view controller and cast it as your view controller
            var viewController = segue.destination as! DetailViewController
            // your new view controller should have property that will store passed value
            //viewController.passedValue = valueToPass
        }
    }
 

    //picker view methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    //xml parsing logic
    // method is sent by the parser object when the start tag of "<recipe>" is encountered.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "recipe" {
            recipeTitle = String()
            recipeType = String()
        }
        
        self.elementName = elementName
    }
    
    // method is sent by the parser object when the end tag of "</recipe>" is encountered.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "recipe" {
            let recipe = Recipe(title: recipeTitle, type: recipeType) //, ingredients: [""], steps: [""]
            recipes.append(recipe)
        }
    }
    
    // actual parsing is executed. The title and type tags will be parsed and the corresponding properties will be initialized.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "title" {
                recipeTitle += data
                print(recipeTitle)
            } else if self.elementName == "recipe_type" {
                recipeType += data
            }
        }
    }
    
    //Core data handling
    func createData(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let recipeEntity = NSEntityDescription.entity(forEntityName: "Recipe", in: managedContext)!
        
        //add recipe
        for r in recipes{
            
            let recipe = NSManagedObject(entity: recipeEntity, insertInto: managedContext)
            recipe.setValue(r.title, forKey: "title")
            recipe.setValue(r.type, forKey: "recipe_type")
        }
        
        //save the data
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "title") as! String)
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    func updateData(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "title = %@", recipeTitle)
        do
        {
            let temp = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = temp[0] as! NSManagedObject
            objectUpdate.setValue("", forKey: "title")
            objectUpdate.setValue("", forKey: "recipe_type")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    func deleteData(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "title = %@", recipeTitle)
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
            
        }
        catch
        {
            print(error)
        }
    }
}
