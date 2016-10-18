//
//  DataObjects.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/6/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import Foundation

class CaseData: NSObject
{
    var caseno = ""
    var firstName = ""
    var lastName = ""
    var dob = ""
    var receivedDate = ""
    var accessionedDate = ""
    var specimens:[Specimen] = []
}

class Specimen: NSObject
{
    var specimenCode = ""
    var siteName = ""
    var tissue = ""
    var procedure = ""
    var numberOfCassettes = ""
    var numberOfSlides = ""
    var specimen = ""
    var cassette = ""
    var slide = ""
    var specimenTitle = ""
    var isVerified = false
    var caseNo = ""
    var internalId = ""
    var grossingId = ""
    var embeddingId = ""
    var stainingId = ""
    var qaId = ""
    var microtomeId = ""
    var specimenId = ""
    var accessionNo = ""
}

class Notes: NSObject
{
    var notesId = ""
    var notes = ""
    var createdTime = ""
}



