

//
//  Enum.swift
//  strum86
//
//  Created by aipxperts on 31/08/17.
//  Copyright © 2017 aipxperts. All rights reserved.
//


import Foundation

enum ALERT : String {
    case warningTitle	= "Warning"
    case DefaultTitle	= "Jazzro"
    case ErrorTitle		= "Error"
    case AddedTitle     = "Added!"
}


enum JOURNAL_TYPE : Int {
    case sleepDetail = 0
    case waterIntake
    case nutrition
    case fitness
    case energyAndMindset
    case lessonLearned
}


enum UserLoginPageFlow:String
{
    case LoginByFB = "login_by_facebook"
    case LoginByGP = "login_by_google"
}

enum MusicTastePageFlow:String
{
    case OpenFirstTime = "FirstMusicTasteSetUp"
    case SideMenuToMusicTaste = "EditMusicTaste"
}



