//
//  BookSection.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookSection.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import Foundation
import SwiftUI

struct BookSection: Identifiable {
    let id = UUID()
    var sectionName: String
    var books: [Book]
    
    
}

extension BookSection {
    static var sections: [BookSection] {
        return [
            .drToast,
            .freeBooks,
            .kevin,
            .arty,
            .patrick
        ]
    }
    
    static var moreSections: [BookSection] {
        return [littlebooks]
    }
    
    static var patrickChannel: [BookSection] {
        return [patrick]
    }
    
    static var singleFeature: BookSection {
        return BookSection(sectionName: "👀 Brand New", books: sampleBooks.filter{$0.featured})
    }
    
    static var featured: BookSection {
        return BookSection(sectionName: "⭐️ Featured", books: sampleBooks.filter{$0.featured}.shuffled())
    }
    
    static var somethingNew: BookSection {
        return BookSection(sectionName: "⚡️ New Storybooks", books: sampleBooks.filter{$0.new}.shuffled())
    }
    
    static var topRated: BookSection {
        return BookSection(sectionName: "🔥 Trending", books: sampleBooks.filter{$0.topRated}.shuffled())
    }
    
    static var littlebooks: BookSection {
        return BookSection(sectionName: "⏳ 5 Minute Storybooks", books: sampleBooks.filter{$0.littlebook}.shuffled())
    }
    static var patrick: BookSection {
        return BookSection(sectionName: "Meet Patrick", books: sampleBooks.filter{$0.characters.contains("patrick")}.shuffled())
    }
    static var arty: BookSection {
        return BookSection(sectionName: "Meet Arty", books: sampleBooks.filter{$0.characters.contains("arty")}.shuffled())
    }
    static var kevin: BookSection {
        return BookSection(sectionName: "Meet Kevin", books: sampleBooks.filter{$0.characters.contains("kevin")}.shuffled())
    }
    static var drToast: BookSection {
        return BookSection(sectionName: "Meet Dr Toast", books: sampleBooks.filter{$0.characters.contains("dr toast")}.shuffled())
    }
    static var freeBooks: BookSection {
        return BookSection(sectionName: "Read for Free", books: sampleBooks.filter{$0.free}.shuffled())
    }
    
    static var favorites: BookSection {
            let favoritedBooks = sampleBooks.filter { UserDefaults.standard.bool(forKey: "favorite_\($0.id)") }
            return BookSection(sectionName: "❤️ Favorites", books: favoritedBooks)
        }
    
    static var sampleBooks: [Book] {
        return [
            Book(
                id: "sheepover",
                title: "Sheep Over",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["patrick", "kevin", "arty", "dr. toast", "woolbert"],
                littlebook: false,
                topRated: true,
                posterImage: "SheepOver",
                promoImage: "SheepOver_promo",
                details: "When Patrick tries counting sheep to fall asleep, the sheep have other plans! They escape his imagination and wreak woolly chaos across town.",
                bookUrl: "",
                pages: [
                    "SheepOver_000", "SheepOver_001", "SheepOver_002", "SheepOver_003", "SheepOver_004", "SheepOver_005", "SheepOver_006", "SheepOver_007", "SheepOver_008", "SheepOver_009", "SheepOver_010", "SheepOver_011", "SheepOver_012", "SheepOver_013", "SheepOver_014", "SheepOver_015", "SheepOver_016", "SheepOver_017", "SheepOver_018", "SheepOver_019", "SheepOver_020", "SheepOver_021", "SheepOver_022", "SheepOver_023", "SheepOver_024", "SheepOver_025", "SheepOver_026", "SheepOver_027", "SheepOver_028", "SheepOver_029", "SheepOver_030", "SheepOver_031", "SheepOver_032", "SheepOver_033", "SheepOver_034", "SheepOver_035", "SheepOver_036", "SheepOver_037", "SheepOver_038"]),
            Book(
                id: "earworm",
                title: "Earworm",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["patrick", "kevin", "arty", "dr. toast", "barry the big brown bear", "mega burrito"],
                littlebook: false,
                topRated: true,
                posterImage: "Earworm",
                promoImage: "Earworm_promo",
                details: "When Patrick discovers his favorite song, he can't stop listening to it—or hearing it in his head! The catchy tune drives him absolutely bananas as it plays on endless repeat. Will Dr. Toast, Barry the Bear, Kevin, and Arty find a way to help their friend escape this musical madness?",
                bookUrl: "",
                pages: [
                    "Earworm_000", "Earworm_001", "Earworm_002", "Earworm_003", "Earworm_004", "Earworm_005", "Earworm_006", "Earworm_007", "Earworm_008", "Earworm_009", "Earworm_010", "Earworm_011", "Earworm_012", "Earworm_013", "Earworm_014", "Earworm_015", "Earworm_016", "Earworm_017", "Earworm_018", "Earworm_019", "Earworm_020", "Earworm_021", "Earworm_022", "Earworm_023", "Earworm_024", "Earworm_025", "Earworm_026", "Earworm_027", "Earworm_028", "Earworm_029", "Earworm_030", "Earworm_031", "Earworm_032", "Earworm_033", "Earworm_034", "Earworm_035", "Earworm_036", "Earworm_037", "Earworm_038", "Earworm_039", "Earworm_040", "Earworm_041", "Earworm_042", "Earworm_043", "Earworm_044"]),
            Book(
                id: "colonelgooseberry",
                title: "Colonel Gooseberry and the Raiders of the New Light",
                featured: true,
                free: true,
                isPurchased: false,
                new: true,
                characters: ["colonel gooseberry"],
                littlebook: false,
                topRated: true,
                posterImage: "ColonelGooseberry",
                promoImage: "ColonelGooseberry_promo",
                details: "When a curious little Gooseberry stays up past bedtime and discovers how dark the garden becomes at night, she accidentally stubs her toe in the darkness. This innocent mishap sparks an epic adventure as Colonel Gooseberry rallies his community to solve the *darkness problem* once and for all.",
                bookUrl: "",
                pages: [
                    "ColonelGooseberry_000", "ColonelGooseberry_001", "ColonelGooseberry_002", "ColonelGooseberry_003", "ColonelGooseberry_004", "ColonelGooseberry_005", "ColonelGooseberry_006", "ColonelGooseberry_007", "ColonelGooseberry_008", "ColonelGooseberry_009", "ColonelGooseberry_010", "ColonelGooseberry_011", "ColonelGooseberry_012", "ColonelGooseberry_013", "ColonelGooseberry_014", "ColonelGooseberry_015", "ColonelGooseberry_016", "ColonelGooseberry_017", "ColonelGooseberry_018", "ColonelGooseberry_019", "ColonelGooseberry_020", "ColonelGooseberry_021", "ColonelGooseberry_022", "ColonelGooseberry_023", "ColonelGooseberry_024", "ColonelGooseberry_025", "ColonelGooseberry_026", "ColonelGooseberry_027", "ColonelGooseberry_028", "ColonelGooseberry_029", "ColonelGooseberry_030", "ColonelGooseberry_031", "ColonelGooseberry_032", "ColonelGooseberry_033", "ColonelGooseberry_034"]),
            
            Book(
                                       id: "housesit",
                                       title: "House Sit",
                                       featured: false,
                                       free: true,
                                       isPurchased: false,
                                       new: false,
                                       characters: ["patrick", "arty"],
                                       littlebook: false,
                                       topRated: true,
                                       posterImage: "HouseSit",
                                       promoImage: "HouseSit_promo",
                                       details: "Arty had a long, relaxing vacation planned, and Patrick was going to house sit. The same Patrick who had a habit of causing chaos everywhere he went. Arty was suddenly very concerned.",
                                       bookUrl: "",
                                       pages: [
                                           "HouseSit_000", "HouseSit_001", "HouseSit_002", "HouseSit_003", "HouseSit_004", "HouseSit_005", "HouseSit_006", "HouseSit_007", "HouseSit_008", "HouseSit_009", "HouseSit_010", "HouseSit_011", "HouseSit_012", "HouseSit_013", "HouseSit_014", "HouseSit_015", "HouseSit_016", "HouseSit_017", "HouseSit_018", "HouseSit_019", "HouseSit_020", "HouseSit_021", "HouseSit_022", "HouseSit_023", "HouseSit_024", "HouseSit_025", "HouseSit_026", "HouseSit_027", "HouseSit_028", "HouseSit_029", "HouseSit_030", "HouseSit_031", "HouseSit_032", "HouseSit_033", "HouseSit_034", "HouseSit_035", "HouseSit_036"]),
            Book(
                                       id: "fireworks",
                                       title: "Fireworks",
                                       featured: true,
                                       free: true,
                                       isPurchased: false,
                                       new: true,
                                       characters: ["patrick", "dr toast", "arty", "kevin"],
                                       littlebook: false,
                                       topRated: true,
                                       posterImage: "Fireworks",
                                       promoImage: "Fireworks_promo",
                                       details: "When Patrick can't wait for the big Rubbishtown parade fireworks, he decides to make his own - how hard could it be? Armed with alarm clocks, a hairdryer, and lots of glitter, Patrick is convinced he's cracked the fireworks code. But when Dr. Toast arrives just in time for Patrick's *scientific* experiment, things don't go quite as planned.",
                                       bookUrl: "",
                                       pages: [
                                           "Fireworks_000", "Fireworks_001", "Fireworks_002", "Fireworks_003", "Fireworks_004", "Fireworks_005", "Fireworks_006", "Fireworks_007", "Fireworks_008", "Fireworks_009", "Fireworks_010", "Fireworks_011", "Fireworks_012", "Fireworks_013", "Fireworks_014", "Fireworks_015", "Fireworks_016", "Fireworks_017", "Fireworks_018", "Fireworks_019", "Fireworks_020", "Fireworks_021", "Fireworks_022", "Fireworks_023", "Fireworks_024", "Fireworks_025", "Fireworks_026", "Fireworks_027", "Fireworks_028", "Fireworks_029", "Fireworks_030", "Fireworks_031", "Fireworks_032"]),
            Book(
                            id: "measuringup",
                            title: "Measuring Up",
                            featured: true,
                            free: false,
                            isPurchased: false,
                            new: true,
                            characters: ["klaus", "patrick", "dr toast"],
                            littlebook: false,
                            topRated: true,
                            posterImage: "MeasuringUp",
                            promoImage: "MeasuringUp_promo",
                            details: "Dr. Toast is panicking: his seemingly perfect brother Klaus is coming to visit! Klaus has supposedly been to space, won judo championships, and rescues cats while baking fancy cakes. But when Klaus arrives with his measuring tape, declaring everything the wrong size and fluffiness, the day takes an unexpected turn. Between lunch disasters, dizzy space stories, and a cat named Disappointment, this tale of two very different brothers delivers plenty of laughs and one surprisingly sweet measurement that changes everything.",
                            bookUrl: "",
                            pages: [
                                "MeasuringUp_000", "MeasuringUp_001", "MeasuringUp_002", "MeasuringUp_003", "MeasuringUp_004", "MeasuringUp_005", "MeasuringUp_006", "MeasuringUp_007", "MeasuringUp_008", "MeasuringUp_009", "MeasuringUp_010", "MeasuringUp_011", "MeasuringUp_012", "MeasuringUp_013", "MeasuringUp_014", "MeasuringUp_015", "MeasuringUp_016", "MeasuringUp_017", "MeasuringUp_018", "MeasuringUp_019", "MeasuringUp_020", "MeasuringUp_021", "MeasuringUp_022", "MeasuringUp_023", "MeasuringUp_024", "MeasuringUp_025", "MeasuringUp_026", "MeasuringUp_027", "MeasuringUp_028", "MeasuringUp_029", "MeasuringUp_030", "MeasuringUp_031", "MeasuringUp_032", "MeasuringUp_033", "MeasuringUp_034", "MeasuringUp_035", "MeasuringUp_036", "MeasuringUp_037", "MeasuringUp_038", "MeasuringUp_039", "MeasuringUp_040", "MeasuringUp_041", "MeasuringUp_042", "MeasuringUp_043", "MeasuringUp_044", "MeasuringUp_045", "MeasuringUp_046", "MeasuringUp_047", "MeasuringUp_048", "MeasuringUp_049", "MeasuringUp_050", "MeasuringUp_051", "MeasuringUp_052", "MeasuringUp_053", "MeasuringUp_054", "MeasuringUp_055"]),
                       
            Book(
                id: "costumeparty",
                title: "Costume Party",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["kevin", "patrick", "arty", "dr toast", "mr taco", "penelope pineapple"],
                littlebook: false,
                topRated: true,
                posterImage: "CostumeParty",
                promoImage: "CostumeParty_promo",
                details: "When boredom strikes, Kevin has a brilliant idea—throw the most spectacular costume party ever! Patrick, Arty, Dr. Toast, Mr. Taco, and Penelope Pineapple are all invited, but Kevin can't decide on the perfect costume. Cowboys, pirates, bunnies, and vampires arrive at his door, but Kevin's mysterious costume choice leads to a surprising twist that will have little readers giggling with delight.",
                bookUrl: "",
                pages: [
                    "CostumeParty_000", "CostumeParty_001", "CostumeParty_002", "CostumeParty_003", "CostumeParty_004", "CostumeParty_005", "CostumeParty_006", "CostumeParty_007", "CostumeParty_008", "CostumeParty_009", "CostumeParty_010", "CostumeParty_011", "CostumeParty_012", "CostumeParty_013", "CostumeParty_014", "CostumeParty_015", "CostumeParty_016", "CostumeParty_017", "CostumeParty_018", "CostumeParty_019", "CostumeParty_020", "CostumeParty_021", "CostumeParty_022", "CostumeParty_023", "CostumeParty_024", "CostumeParty_025", "CostumeParty_026", "CostumeParty_027", "CostumeParty_028", "CostumeParty_029", "CostumeParty_030", "CostumeParty_031", "CostumeParty_032"]),
           
            Book(
                id: "wreakcoons",
                title: "Wreakcoons",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["wreakcoons", "benny", "fleur", "rodney", "gwen", "patrick"],
                littlebook: false,
                topRated: true,
                posterImage: "Wreakcoons",
                promoImage: "Wreakcoons_promo",
                details: "Meet the Wreakcoons, a crew of highly skilled destruction experts. When Patrick calls the crew in for a simple wall removal, their enthusiasm leads to unexpected chaos. But with a little creativity and teamwork, these raccoons discover that building can be just as rewarding as wrecking. Join Benny, Fleur, Rodney, and Gwen as they transform from demolition experts to 'Rebuildercoons' in this heartwarming tale.",
                bookUrl: "",
                pages: [
                    "Wreakcoons_000", "Wreakcoons_001", "Wreakcoons_002", "Wreakcoons_003", "Wreakcoons_004", "Wreakcoons_005", "Wreakcoons_006", "Wreakcoons_007", "Wreakcoons_008", "Wreakcoons_009", "Wreakcoons_010", "Wreakcoons_011", "Wreakcoons_012", "Wreakcoons_013", "Wreakcoons_014", "Wreakcoons_015", "Wreakcoons_016", "Wreakcoons_017", "Wreakcoons_018", "Wreakcoons_019", "Wreakcoons_020", "Wreakcoons_021", "Wreakcoons_022", "Wreakcoons_023", "Wreakcoons_024", "Wreakcoons_025", "Wreakcoons_026", "Wreakcoons_027", "Wreakcoons_028", "Wreakcoons_029", "Wreakcoons_030", "Wreakcoons_031", "Wreakcoons_032", "Wreakcoons_033", "Wreakcoons_034", "Wreakcoons_035", "Wreakcoons_036", "Wreakcoons_037"]),
            Book(
                id: "chaosterrormarshmallows",
                title: "Chaos! Terror! Marshmallows!",
                featured: true,
                free: true,
                isPurchased: false,
                new: true,
                characters: ["marvin", "ugarth"],
                littlebook: false,
                topRated: true,
                posterImage: "Marshmallow",
                promoImage: "Marshmallow_promo",
                details: "When Ugarth the Harbinger of Doom emerges from the shadow realm, he meets his match in Marvin, a mellow marshmallow with a knack for hospitality. In this spooky tale, chaos and terror give way to herbal tea and flapjacks as Marvin proves that even the grumpiest demon is no match for the power of coziness.",
                bookUrl: "",
                pages: [
                    "Marshmallow_000", "Marshmallow_001", "Marshmallow_002", "Marshmallow_003", "Marshmallow_004", "Marshmallow_005", "Marshmallow_006", "Marshmallow_007", "Marshmallow_008", "Marshmallow_009", "Marshmallow_010", "Marshmallow_011", "Marshmallow_012", "Marshmallow_013", "Marshmallow_014", "Marshmallow_015", "Marshmallow_016", "Marshmallow_017", "Marshmallow_018", "Marshmallow_019", "Marshmallow_020", "Marshmallow_021", "Marshmallow_022", "Marshmallow_023", "Marshmallow_024", "Marshmallow_025", "Marshmallow_026", "Marshmallow_027", "Marshmallow_028", "Marshmallow_029", "Marshmallow_030", "Marshmallow_031", "Marshmallow_032", "Marshmallow_033", "Marshmallow_034", "Marshmallow_035", "Marshmallow_036", "Marshmallow_037", "Marshmallow_038", "Marshmallow_039", "Marshmallow_040", "Marshmallow_041", "Marshmallow_042", "Marshmallow_043", "Marshmallow_044", "Marshmallow_045"]),
            Book(
                id: "taconauts",
                title: "Taconauts",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["patrick", "mr taco"],
                littlebook: false,
                topRated: true,
                posterImage: "Taconauts",
                promoImage: "Taconauts_promo",
                details: "Mr Taco blasts off to retrieve Patrick's runaway balloon, but a moon alien and potential intergalactic war weren't part of the flight plan.",
                bookUrl: "Taconauts.mp4",
                pages: [
                    "Taconauts_000", "Taconauts_001", "Taconauts_002", "Taconauts_003", "Taconauts_004", "Taconauts_005", "Taconauts_006", "Taconauts_007", "Taconauts_008", "Taconauts_009", "Taconauts_010", "Taconauts_011", "Taconauts_012", "Taconauts_013", "Taconauts_014", "Taconauts_015", "Taconauts_016", "Taconauts_017", "Taconauts_018", "Taconauts_019", "Taconauts_020", "Taconauts_021", "Taconauts_022", "Taconauts_023", "Taconauts_024", "Taconauts_025", "Taconauts_026", "Taconauts_027", "Taconauts_028", "Taconauts_029", "Taconauts_030", "Taconauts_031", "Taconauts_032", "Taconauts_033", "Taconauts_034", "Taconauts_035", "Taconauts_036", "Taconauts_037"]),
            Book(
                id: "onemorething",
                title: "One More Thing",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["arty", "patrick"],
                littlebook: false,
                topRated: true,
                posterImage: "OneMoreThing",
                promoImage: "OneMoreThing_promo",
                details: "It was snowy day and Patrick wasn't feeling well. Arty wanted to help Patrick, who had a few requests.",
                bookUrl: "OneMoreThing.mp4",
                pages: [
                    "OneMoreThing_000", "OneMoreThing_001", "OneMoreThing_002", "OneMoreThing_003", "OneMoreThing_004", "OneMoreThing_005", "OneMoreThing_006", "OneMoreThing_007", "OneMoreThing_008", "OneMoreThing_009", "OneMoreThing_010", "OneMoreThing_011", "OneMoreThing_012", "OneMoreThing_013", "OneMoreThing_014", "OneMoreThing_015", "OneMoreThing_016", "OneMoreThing_017", "OneMoreThing_018", "OneMoreThing_019", "OneMoreThing_020", "OneMoreThing_021", "OneMoreThing_022", "OneMoreThing_023", "OneMoreThing_024", "OneMoreThing_025", "OneMoreThing_026", "OneMoreThing_027", "OneMoreThing_028", "OneMoreThing_029", "OneMoreThing_030", "OneMoreThing_031", "OneMoreThing_032", "OneMoreThing_033", "OneMoreThing_034", "OneMoreThing_035", "OneMoreThing_036", "OneMoreThing_037", "OneMoreThing_038", "OneMoreThing_039", "OneMoreThing_040"]),
            
            Book(
                id: "bubblegum",
                title: "Bubblegum",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["kevin"],
                littlebook: false,
                topRated: true,
                posterImage: "Bubblegum",
                promoImage: "Bubblegum_promo",
                details: "Blow and behold! Chew the impossible! The new unstoppable, unpoppable Big Bubble Bubblegum. Join Kevin on a big bubble adventure that's truly out of this world.",
                bookUrl: "Bubblegum.mp4",
                pages: [
                    "bubblegum_000", "bubblegum_001", "bubblegum_002", "bubblegum_003", "bubblegum_004", "bubblegum_005", "bubblegum_006", "bubblegum_007", "bubblegum_008", "bubblegum_009", "bubblegum_010", "bubblegum_011", "bubblegum_012", "bubblegum_013", "bubblegum_014", "bubblegum_015", "bubblegum_016", "bubblegum_017", "bubblegum_018", "bubblegum_019", "bubblegum_020", "bubblegum_021", "bubblegum_022", "bubblegum_023", "bubblegum_024", "bubblegum_025", "bubblegum_026", "bubblegum_027", "bubblegum_028", "bubblegum_029", "bubblegum_030", "bubblegum_031", "bubblegum_032", "bubblegum_033", "bubblegum_034", "bubblegum_035"]),

            Book(
                id: "followthatduck",
                title: "Follow That Duck",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["arty", "patrick", "kevin"],
                            littlebook: false,
                            topRated: true,
                            posterImage: "FollowThatDuck",
                            promoImage: "FollowThatDuck_promo",
                            details: "Oh no! The little duck has taken Arty's magic wand! And now it's causing all sorts of trouble!\n\nQuick Arty! Follow that duck!",
                            bookUrl: "FollowThatDuck.mp4",
                            pages: [
                                "Duck_000", "Duck_001", "Duck_002", "Duck_003", "Duck_004", "Duck_005", "Duck_006", "Duck_007", "Duck_008", "Duck_009", "Duck_010", "Duck_011", "Duck_012", "Duck_013", "Duck_014", "Duck_015", "Duck_016", "Duck_017", "Duck_018", "Duck_019", "Duck_020", "Duck_021", "Duck_022", "Duck_023", "Duck_024", "Duck_025"]),
                                
            Book(
                            id: "thechristmasstakeout",
                            title: "The Christmas Stake-Out",
                            featured: false,
                            free: false,
                            isPurchased: false,
                            new: true,
                            characters: ["patrick"],
                            littlebook: false,
                            topRated: true,
                            posterImage: "StakeOut",
                            promoImage: "StakeOut_promo",
                            details: "It was Christmas Eve and Patrick had a plan to finally catch Santa! He was prepared: Santa bait (cookies); binoculars, a camera, and smooth jazz. He was ready. That is, until the gnomes showed up...\n\nJoin Patrick - and more gnomes than you can shake a porcelain fish at - on a magical holiday adventure to save Christmas!",
                            bookUrl: "TheChristmasStakeOut.mp4",
                            pages: [
                                "StakeOut_000", "StakeOut_001", "StakeOut_002", "StakeOut_003", "StakeOut_004", "StakeOut_005", "StakeOut_006", "StakeOut_007", "StakeOut_008", "StakeOut_009", "StakeOut_010", "StakeOut_011", "StakeOut_012", "StakeOut_013", "StakeOut_014", "StakeOut_015", "StakeOut_016", "StakeOut_017", "StakeOut_018", "StakeOut_019", "StakeOut_020", "StakeOut_021", "StakeOut_022", "StakeOut_023", "StakeOut_024", "StakeOut_025", "StakeOut_026", "StakeOut_027", "StakeOut_028", "StakeOut_029", "StakeOut_030", "StakeOut_031", "StakeOut_032", "StakeOut_033", "StakeOut_034", "StakeOut_035", "StakeOut_036", "StakeOut_037", "StakeOut_038", "StakeOut_039", "StakeOut_040", "StakeOut_041", "StakeOut_042", "StakeOut_043", "StakeOut_044", "StakeOut_045", "StakeOut_046", "StakeOut_047", "StakeOut_048", "StakeOut_049", "StakeOut_050", "StakeOut_051", "StakeOut_052", "StakeOut_053", "StakeOut_054", "StakeOut_055", "StakeOut_056", "StakeOut_057", "StakeOut_058", "StakeOut_059"]),
                                
            Book(
                            id: "footprints",
                            title: "Footprints",
                            featured: true,
                            free: false,
                            isPurchased: false,
                            new: true,
                            characters: ["patrick", "kevin", "arty"],
                            littlebook: false,
                            topRated: true,
                            posterImage: "Footprints",
                            promoImage: "Footprints_promo",
                            details: "Join Patrick in another delightfully curious adventure across Sardine Shores, Long Cat City, and Cactus Sands.\n\nThere are giant, mysterious footprints all across town, and Patrick is on a mission to track them down. Even when they lead to the most unexpected of places...",
                            bookUrl: "Footprints.mp4",
                            pages: [
                                "Footprints_000", "Footprints_001", "Footprints_002", "Footprints_003", "Footprints_004", "Footprints_005", "Footprints_006", "Footprints_007", "Footprints_008", "Footprints_009", "Footprints_010", "Footprints_011", "Footprints_012", "Footprints_013", "Footprints_014", "Footprints_015", "Footprints_016", "Footprints_017", "Footprints_018", "Footprints_019", "Footprints_020", "Footprints_021", "Footprints_022", "Footprints_023", "Footprints_024", "Footprints_025", "Footprints_026", "Footprints_027", "Footprints_028", "Footprints_029", "Footprints_030", "Footprints_031", "Footprints_032", "Footprints_033", "Footprints_034", "Footprints_035", "Footprints_036", "Footprints_037", "Footprints_038", "Footprints_039", "Footprints_040"]),

            Book(
                            id: "surprise",
                            title: "Surprise",
                            featured: true,
                            free: false,
                            isPurchased: false,
                            new: true,
                            characters: ["patrick", "arty"],
                            littlebook: false,
                            topRated: true,
                            posterImage: "Surprise",
                            promoImage: "Surprise_promo",
                            details: "Arty has a surprise for Patrick, but Patrick will have to wait to open it.\n\nUnfortunately, Patrick is not a very patient little monster.",
                            bookUrl: "Surprise.mp4",
                            pages: [
                                "Surprise_001", "Surprise_002", "Surprise_003", "Surprise_004", "Surprise_005", "Surprise_006", "Surprise_007", "Surprise_008", "Surprise_009", "Surprise_010", "Surprise_011", "Surprise_012", "Surprise_013", "Surprise_014", "Surprise_015", "Surprise_016", "Surprise_017", "Surprise_018", "Surprise_019", "Surprise_020", "Surprise_021", "Surprise_022", "Surprise_023", "Surprise_024", "Surprise_025", "Surprise_026", "Surprise_027", "Surprise_028", "Surprise_029", "Surprise_030", "Surprise_031", "Surprise_032", "Surprise_033", "Surprise_034", "Surprise_035", "Surprise_036", "Surprise_037", "Surprise_038", "Surprise_039", "Surprise_040", "Surprise_041", "Surprise_042", "Surprise_043", "Surprise_044", "Surprise_045", "Surprise_046", "Surprise_047", "Surprise_048"]),
            
            
            
            Book(
                id: "thebigblueberry",
                title: "The Big Blueberry",
                featured: true,
                free: false,
                isPurchased: false,
                new: true,
                characters: ["blueberry", "strawberry"],
                littlebook: false,
                topRated: true,
                posterImage: "TheBigBlueberry",
                promoImage: "TheBigBlueberry_promo",
                details: "When a giant blueberry appears in Strawberry's garden, it sets off a chain of events that will change both fruits forever. This sweet tale explores themes of friendship, acceptance, and the joy of being different.",
                bookUrl: "TheBigBlueberry.mp4",
                pages: [
                    "TheBigBlueberry_000", "TheBigBlueberry_001", "TheBigBlueberry_002", "TheBigBlueberry_003", "TheBigBlueberry_004", "TheBigBlueberry_005", "TheBigBlueberry_006", "TheBigBlueberry_007", "TheBigBlueberry_008", "TheBigBlueberry_009", "TheBigBlueberry_010", "TheBigBlueberry_011", "TheBigBlueberry_012", "TheBigBlueberry_013", "TheBigBlueberry_014", "TheBigBlueberry_015", "TheBigBlueberry_016", "TheBigBlueberry_017", "TheBigBlueberry_018", "TheBigBlueberry_019", "TheBigBlueberry_020", "TheBigBlueberry_021", "TheBigBlueberry_022", "TheBigBlueberry_023", "TheBigBlueberry_024", "TheBigBlueberry_025", "TheBigBlueberry_026", "TheBigBlueberry_027", "TheBigBlueberry_028"]),
            Book(
                id: "thecaseofthemissingbanana",
                title: "The Case of the Missing Banana",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "TheCaseOfTheMissingBanana",
                promoImage: "TheCaseOfTheMissingBanana_promo",
                details: "When a prized banana goes missing, Patrick and Kevin team up with Arty to solve the mystery. Follow their detective work as they search for clues and uncover the truth behind the missing banana.",
                bookUrl: "TheCaseOfTheMissingBanana.mp4",
                pages: [
                    "TheCaseOfTheMissingBanana_000", "TheCaseOfTheMissingBanana_001", "TheCaseOfTheMissingBanana_002", "TheCaseOfTheMissingBanana_003", "TheCaseOfTheMissingBanana_004", "TheCaseOfTheMissingBanana_005", "TheCaseOfTheMissingBanana_006", "TheCaseOfTheMissingBanana_007", "TheCaseOfTheMissingBanana_008", "TheCaseOfTheMissingBanana_009", "TheCaseOfTheMissingBanana_010", "TheCaseOfTheMissingBanana_011", "TheCaseOfTheMissingBanana_012", "TheCaseOfTheMissingBanana_013", "TheCaseOfTheMissingBanana_014", "TheCaseOfTheMissingBanana_015", "TheCaseOfTheMissingBanana_016", "TheCaseOfTheMissingBanana_017", "TheCaseOfTheMissingBanana_018", "TheCaseOfTheMissingBanana_019", "TheCaseOfTheMissingBanana_020", "TheCaseOfTheMissingBanana_021", "TheCaseOfTheMissingBanana_022", "TheCaseOfTheMissingBanana_023", "TheCaseOfTheMissingBanana_024", "TheCaseOfTheMissingBanana_025", "TheCaseOfTheMissingBanana_026", "TheCaseOfTheMissingBanana_027", "TheCaseOfTheMissingBanana_028", "TheCaseOfTheMissingBanana_029", "TheCaseOfTheMissingBanana_030", "TheCaseOfTheMissingBanana_031", "TheCaseOfTheMissingBanana_032", "TheCaseOfTheMissingBanana_033", "TheCaseOfTheMissingBanana_034", "TheCaseOfTheMissingBanana_035", "TheCaseOfTheMissingBanana_036", "TheCaseOfTheMissingBanana_037", "TheCaseOfTheMissingBanana_038", "TheCaseOfTheMissingBanana_039", "TheCaseOfTheMissingBanana_040", "TheCaseOfTheMissingBanana_041", "TheCaseOfTheMissingBanana_042", "TheCaseOfTheMissingBanana_043", "TheCaseOfTheMissingBanana_044", "TheCaseOfTheMissingBanana_045"]),

            Book(
                id: "nothingtoworryabout",
                title: "Nothing to Worry About",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "dr toast"],
                littlebook: false,
                topRated: false,
                posterImage: "NothingToWorryAbout",
                promoImage: "NothingToWorryAbout_promo",
                details: "Patrick was bored. He wondered what his friends were doing. Maybe making soup, or going for a run, or catching a big fish. But then again, what if...?",
                bookUrl: "NothingToWorryAbout.mp4",
                pages: [
                    "NothingToWorryAbout_000", "NothingToWorryAbout_001", "NothingToWorryAbout_002", "NothingToWorryAbout_003", "NothingToWorryAbout_004", "NothingToWorryAbout_005", "NothingToWorryAbout_006", "NothingToWorryAbout_007", "NothingToWorryAbout_008", "NothingToWorryAbout_009", "NothingToWorryAbout_010", "NothingToWorryAbout_011", "NothingToWorryAbout_012", "NothingToWorryAbout_013", "NothingToWorryAbout_014", "NothingToWorryAbout_015", "NothingToWorryAbout_016", "NothingToWorryAbout_017", "NothingToWorryAbout_018", "NothingToWorryAbout_019", "NothingToWorryAbout_020", "NothingToWorryAbout_021", "NothingToWorryAbout_022", "NothingToWorryAbout_023", "NothingToWorryAbout_024", "NothingToWorryAbout_025", "NothingToWorryAbout_026", "NothingToWorryAbout_027", "NothingToWorryAbout_028", "NothingToWorryAbout_029", "NothingToWorryAbout_030", "NothingToWorryAbout_031", "NothingToWorryAbout_032", "NothingToWorryAbout_033", "NothingToWorryAbout_034", "NothingToWorryAbout_035", "NothingToWorryAbout_036", "NothingToWorryAbout_037", "NothingToWorryAbout_038", "NothingToWorryAbout_039", "NothingToWorryAbout_040", "NothingToWorryAbout_041", "NothingToWorryAbout_042", "NothingToWorryAbout_043", "NothingToWorryAbout_044", "NothingToWorryAbout_045", "NothingToWorryAbout_046", "NothingToWorryAbout_047", "NothingToWorryAbout_048", "NothingToWorryAbout_049", "NothingToWorryAbout_050", "NothingToWorryAbout_051"]),

            Book(
                id: "sportsday",
                title: "Sports Day",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "mr egg", "miss spider", "big bunny"],
                littlebook: false,
                topRated: true,
                posterImage: "SportsDay",
                promoImage: "SportsDay_promo",
                details: "And for the first event, Patrick will be competing in the egg and spoon race against a literal egg with a spoon taped to their chest.\n\nHang on a minute.",
                bookUrl: "SportsDay.mp4",
                pages: [
                    "SportsDay_000", "SportsDay_001", "SportsDay_002", "SportsDay_003", "SportsDay_004", "SportsDay_005", "SportsDay_006", "SportsDay_007", "SportsDay_008", "SportsDay_009", "SportsDay_010", "SportsDay_011", "SportsDay_012", "SportsDay_013", "SportsDay_014", "SportsDay_015", "SportsDay_016", "SportsDay_017", "SportsDay_018", "SportsDay_019", "SportsDay_020", "SportsDay_021", "SportsDay_022", "SportsDay_023", "SportsDay_024", "SportsDay_025", "SportsDay_026", "SportsDay_027", "SportsDay_028", "SportsDay_029", "SportsDay_030", "SportsDay_031", "SportsDay_032", "SportsDay_033", "SportsDay_034", "SportsDay_035", "SportsDay_036", "SportsDay_037", "SportsDay_038", "SportsDay_039", "SportsDay_040", "SportsDay_041", "SportsDay_042", "SportsDay_043", "SportsDay_044", "SportsDay_045", "SportsDay_046", "SportsDay_047", "SportsDay_048", "SportsDay_049", "SportsDay_050", "SportsDay_051", "SportsDay_052", "SportsDay_053"]),
            Book(
                id: "thebox",
                title: "The Box",
                featured: true,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: true,
                posterImage: "TheBox",
                promoImage: "TheBox_promo",
                details: "Patrick, Kevin and Arty are the best of friends, so when Kevin takes a trip to the Waffle Jungle, Arty and Patrick are very sad to see him go. It's not all bad news though, Kevin left his friends a special surprise to play with while he was gone.\n\nThe question is, what is it?",
                bookUrl: "TheBox.mp4",
                pages: [
                    "TheBox_000", "TheBox_001", "TheBox_002", "TheBox_003", "TheBox_004", "TheBox_005", "TheBox_006", "TheBox_007", "TheBox_008", "TheBox_009", "TheBox_010", "TheBox_011", "TheBox_012", "TheBox_013", "TheBox_014", "TheBox_015", "TheBox_016", "TheBox_017", "TheBox_018", "TheBox_019", "TheBox_020", "TheBox_021", "TheBox_022", "TheBox_023", "TheBox_024", "TheBox_025", "TheBox_026"]),
  
            
            Book(
                id: "forgetmenot",
                title: "Forget Me Not",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "ForgetMeNot",
                promoImage: "ForgetMeNot_promo",
                details: "Patrick had something very important to ask Arty. There was just one problem, he couldn't remember what it was…",
                bookUrl: "ForgetMeNot.mp4",
                pages: [
                    "ForgetMeNot_000", "ForgetMeNot_001", "ForgetMeNot_002", "ForgetMeNot_003", "ForgetMeNot_004", "ForgetMeNot_005", "ForgetMeNot_006", "ForgetMeNot_007", "ForgetMeNot_008", "ForgetMeNot_009", "ForgetMeNot_010", "ForgetMeNot_011", "ForgetMeNot_012", "ForgetMeNot_013", "ForgetMeNot_014", "ForgetMeNot_015", "ForgetMeNot_016", "ForgetMeNot_017", "ForgetMeNot_018", "ForgetMeNot_019", "ForgetMeNot_020", "ForgetMeNot_021", "ForgetMeNot_022", "ForgetMeNot_023", "ForgetMeNot_024", "ForgetMeNot_025", "ForgetMeNot_026", "ForgetMeNot_027", "ForgetMeNot_028", "ForgetMeNot_029", "ForgetMeNot_030", "ForgetMeNot_031", "ForgetMeNot_032", "ForgetMeNot_033", "ForgetMeNot_034", "ForgetMeNot_035", "ForgetMeNot_036"]),
            Book(
                id: "bigscarymonsters",
                title: "Big Scary Monsters",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "jeff from accounting"],
                littlebook: false,
                topRated: false,
                posterImage: "BigScaryMonsters",
                promoImage: "BigScaryMonsters_promo",
                details: "Patrick, Kevin, and Arty head a scary sound. What could it be? It was time to be brave!",
                bookUrl: "BigScaryMonsters.mp4",
                pages: [
                    "BigScaryMonsters_000", "BigScaryMonsters_001", "BigScaryMonsters_002", "BigScaryMonsters_003", "BigScaryMonsters_004", "BigScaryMonsters_005", "BigScaryMonsters_006", "BigScaryMonsters_007", "BigScaryMonsters_008", "BigScaryMonsters_009", "BigScaryMonsters_010", "BigScaryMonsters_011", "BigScaryMonsters_012", "BigScaryMonsters_013", "BigScaryMonsters_014", "BigScaryMonsters_015", "BigScaryMonsters_016", "BigScaryMonsters_017", "BigScaryMonsters_018", "BigScaryMonsters_019", "BigScaryMonsters_020", "BigScaryMonsters_021", "BigScaryMonsters_022", "BigScaryMonsters_023", "BigScaryMonsters_024", "BigScaryMonsters_025", "BigScaryMonsters_026", "BigScaryMonsters_027", "BigScaryMonsters_028", "BigScaryMonsters_029", "BigScaryMonsters_030", "BigScaryMonsters_031", "BigScaryMonsters_032", "BigScaryMonsters_033", "BigScaryMonsters_034", "BigScaryMonsters_035", "BigScaryMonsters_036", "BigScaryMonsters_037", "BigScaryMonsters_038", "BigScaryMonsters_039", "BigScaryMonsters_040", "BigScaryMonsters_041", "BigScaryMonsters_042"]),
            Book(
                id: "bigfish",
                title: "Big Fish",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["francois", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "BigFish",
                promoImage: "BigFish_promo",
                details: "Arty won a special prize at the fair: a new pet fish! He named him Francois. But Francois was a chunky fish. He kept outgrowing his fish bowls.\n\nThis was a very chonky problem.",
                bookUrl: "BigFish.mp4",
                pages: [
                    "BigFish_000", "BigFish_001", "BigFish_002", "BigFish_003", "BigFish_004", "BigFish_005", "BigFish_006", "BigFish_007", "BigFish_008", "BigFish_009", "BigFish_010", "BigFish_011", "BigFish_012", "BigFish_013", "BigFish_014", "BigFish_015", "BigFish_016", "BigFish_017", "BigFish_018", "BigFish_019", "BigFish_020", "BigFish_021", "BigFish_022", "BigFish_023", "BigFish_024", "BigFish_025", "BigFish_026", "BigFish_027", "BigFish_028", "BigFish_029", "BigFish_030", "BigFish_031", "BigFish_032", "BigFish_033"]),
            Book(
                id: "caketastrophe",
                title: "CAKE-TASTROPHE",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "Caketastrophe",
                promoImage: "Caketastrophe_promo",
                details: "Patrick was making a very special cake for Arty's birthday. It had to be *perfect*. Just one cup of flour? That can't be right. Two eggs? Nah. This cake will be the BEST in town.",
                bookUrl: "Caketastrophe.mp4",
                pages: [
                    "Caketastrophe_000", "Caketastrophe_001", "Caketastrophe_002", "Caketastrophe_003", "Caketastrophe_004", "Caketastrophe_005", "Caketastrophe_006", "Caketastrophe_007", "Caketastrophe_008", "Caketastrophe_009", "Caketastrophe_010", "Caketastrophe_011", "Caketastrophe_012", "Caketastrophe_013", "Caketastrophe_014", "Caketastrophe_015", "Caketastrophe_016", "Caketastrophe_017", "Caketastrophe_018", "Caketastrophe_019", "Caketastrophe_020", "Caketastrophe_021", "Caketastrophe_022", "Caketastrophe_023", "Caketastrophe_024", "Caketastrophe_025", "Caketastrophe_026", "Caketastrophe_027", "Caketastrophe_028", "Caketastrophe_029", "Caketastrophe_030", "Caketastrophe_031", "Caketastrophe_032", "Caketastrophe_033"]),
            Book(
                id: "theexpert",
                title: "The Expert",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: false,
                topRated: true,
                posterImage: "TheExpert",
                promoImage: "TheExpert_promo",
                details: "Arty was going camping with Patrick. Patrick thought he knew all about camping. Which may have been a *slight* exaggeration.",
                bookUrl: "TheExpert.mp4",
                pages: [
                    "TheExpert_000", "TheExpert_001", "TheExpert_002", "TheExpert_003", "TheExpert_004", "TheExpert_005", "TheExpert_006", "TheExpert_007", "TheExpert_008", "TheExpert_009", "TheExpert_010", "TheExpert_011", "TheExpert_012", "TheExpert_013", "TheExpert_014", "TheExpert_015", "TheExpert_016", "TheExpert_017", "TheExpert_018", "TheExpert_019", "TheExpert_020", "TheExpert_021", "TheExpert_022", "TheExpert_023", "TheExpert_024", "TheExpert_025", "TheExpert_026"]),
  
            Book(
                id: "aspotofbother",
                title: "A Spot of Bother",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "dr toast", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "ASpotOfBother",
                promoImage: "ASpotOfBother_promo",
                details: "Patrick is not feeling very well. He's covered in bright red spots.\n\nNot to worry, Arty has an idea!\n\nWhat could possibly go wrong?",
                bookUrl: "ASpotOfBother.mp4",
                pages: [
                    "ASpotOfBother_000", "ASpotOfBother_001", "ASpotOfBother_002", "ASpotOfBother_003", "ASpotOfBother_004", "ASpotOfBother_005", "ASpotOfBother_006", "ASpotOfBother_007", "ASpotOfBother_008", "ASpotOfBother_009", "ASpotOfBother_010", "ASpotOfBother_011", "ASpotOfBother_012", "ASpotOfBother_013", "ASpotOfBother_014", "ASpotOfBother_015", "ASpotOfBother_016", "ASpotOfBother_017", "ASpotOfBother_018", "ASpotOfBother_019", "ASpotOfBother_020", "ASpotOfBother_021", "ASpotOfBother_022", "ASpotOfBother_023", "ASpotOfBother_024", "ASpotOfBother_025", "ASpotOfBother_026", "ASpotOfBother_027", "ASpotOfBother_028", "ASpotOfBother_029", "ASpotOfBother_030", "ASpotOfBother_031", "ASpotOfBother_032", "ASpotOfBother_033", "ASpotOfBother_034", "ASpotOfBother_035", "ASpotOfBother_036"]),

            Book(
                id: "averyhairylittlemonster",
                title: "A Very Hairy Little Monster",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "AVeryHairyLittleMonster",
                promoImage: "AVeryHairyLittleMonster_promo",
                details: "When it comes to little monster hair, Kevin has the best mop in all of Rubbish Town. He's been crowned 'Greatest Hair' 28 consecutive times at the Rubbish Town Fair and if things go well today, he'll make it 29!\n\nCome and see Kevin at the 'Greatest Hair' award ceremony - what could possibly go wrong...",
                bookUrl: "AVeryHairyLittleMonster.mp4",
                pages: [
                    "AVeryHairyLittleMonster_000", "AVeryHairyLittleMonster_001", "AVeryHairyLittleMonster_002", "AVeryHairyLittleMonster_003", "AVeryHairyLittleMonster_004", "AVeryHairyLittleMonster_005", "AVeryHairyLittleMonster_006", "AVeryHairyLittleMonster_007", "AVeryHairyLittleMonster_008", "AVeryHairyLittleMonster_009", "AVeryHairyLittleMonster_010", "AVeryHairyLittleMonster_011", "AVeryHairyLittleMonster_012", "AVeryHairyLittleMonster_013", "AVeryHairyLittleMonster_014", "AVeryHairyLittleMonster_015", "AVeryHairyLittleMonster_016", "AVeryHairyLittleMonster_017", "AVeryHairyLittleMonster_018", "AVeryHairyLittleMonster_019", "AVeryHairyLittleMonster_020", "AVeryHairyLittleMonster_021", "AVeryHairyLittleMonster_022", "AVeryHairyLittleMonster_023", "AVeryHairyLittleMonster_024", "AVeryHairyLittleMonster_025", "AVeryHairyLittleMonster_026", "AVeryHairyLittleMonster_027", "AVeryHairyLittleMonster_028", "AVeryHairyLittleMonster_029", "AVeryHairyLittleMonster_030", "AVeryHairyLittleMonster_031", "AVeryHairyLittleMonster_032", "AVeryHairyLittleMonster_033", "AVeryHairyLittleMonster_034", "AVeryHairyLittleMonster_035", "AVeryHairyLittleMonster_036", "AVeryHairyLittleMonster_037", "AVeryHairyLittleMonster_038", "AVeryHairyLittleMonster_039", "AVeryHairyLittleMonster_040", "AVeryHairyLittleMonster_041", "AVeryHairyLittleMonster_042", "AVeryHairyLittleMonster_043", "AVeryHairyLittleMonster_044", "AVeryHairyLittleMonster_045"]),
            Book(
                id: "anartyforallseasons",
                title: "An Arty For All Seasons",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: true,
                posterImage: "AnArtyForAllSeasons",
                promoImage: "AnArtyForAllSeasons_promo",
                details: "It had been an exceedingly grey day in Rubbish Town, and Arty knew why: Winter was coming.\n\nArty does not like winter, he does not like winter At All. The cold air, the frost on the ground, the snow. Oh, the snow! What a disaster!\n\nWouldn't it be great if he could just SKIP the whole unpleasant season?",
                bookUrl: "AnArtyForAllSeasons.mp4",
                pages: [
                    "AnArtyForAllSeasons_000", "AnArtyForAllSeasons_001", "AnArtyForAllSeasons_002", "AnArtyForAllSeasons_003", "AnArtyForAllSeasons_004", "AnArtyForAllSeasons_005", "AnArtyForAllSeasons_006", "AnArtyForAllSeasons_007", "AnArtyForAllSeasons_008", "AnArtyForAllSeasons_009", "AnArtyForAllSeasons_010", "AnArtyForAllSeasons_011", "AnArtyForAllSeasons_012", "AnArtyForAllSeasons_013", "AnArtyForAllSeasons_014", "AnArtyForAllSeasons_015", "AnArtyForAllSeasons_016", "AnArtyForAllSeasons_017", "AnArtyForAllSeasons_018", "AnArtyForAllSeasons_019", "AnArtyForAllSeasons_020", "AnArtyForAllSeasons_021", "AnArtyForAllSeasons_022", "AnArtyForAllSeasons_023", "AnArtyForAllSeasons_024", "AnArtyForAllSeasons_025", "AnArtyForAllSeasons_026", "AnArtyForAllSeasons_027", "AnArtyForAllSeasons_028", "AnArtyForAllSeasons_029", "AnArtyForAllSeasons_030", "AnArtyForAllSeasons_031", "AnArtyForAllSeasons_032", "AnArtyForAllSeasons_033"]),
            Book(
                id: "theimpossibledoor",
                title: "The Impossible Door",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "dr toast"],
                littlebook: false,
                topRated: true,
                posterImage: "TheImpossibleDoor",
                promoImage: "TheImpossibleDoor_promo",
                details: "Patrick has just brought home his very heavy shopping bags and is looking forward to a delicious waffle-jam sandwich.\n\nThere's just one problem - Patrick can't seem to open his front door!",
                bookUrl: "https://www.boxfort.co/storybooks/the-impossible-door",
                pages: [
                    "TheImpossibleDoor_000", "TheImpossibleDoor_001", "TheImpossibleDoor_002", "TheImpossibleDoor_003", "TheImpossibleDoor_004", "TheImpossibleDoor_005", "TheImpossibleDoor_006", "TheImpossibleDoor_007", "TheImpossibleDoor_008", "TheImpossibleDoor_009", "TheImpossibleDoor_010", "TheImpossibleDoor_011", "TheImpossibleDoor_012", "TheImpossibleDoor_013", "TheImpossibleDoor_014", "TheImpossibleDoor_015", "TheImpossibleDoor_016", "TheImpossibleDoor_017", "TheImpossibleDoor_018", "TheImpossibleDoor_019", "TheImpossibleDoor_020", "TheImpossibleDoor_021", "TheImpossibleDoor_022", "TheImpossibleDoor_023", "TheImpossibleDoor_024", "TheImpossibleDoor_025"]),
            Book(
                id: "hiccup",
                title: "Hiccup",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "dr toast", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "Hiccup",
                promoImage: "Hiccup_promo",
                details: "Patrick and Arty are headed to the beach when - dun dun derrr - disaster strikes! Arty has...THE HICCUPS!!\n\nWho will save our valiant hero? Step forward world-renowned hiccup expert: Dr Toast.\n\nWill Arty be cured by the croissant or the crumpet? Read 'Hiccup' today and find out.",
                bookUrl: "Hiccup.mp4",
                pages: [
                    "Hiccup_000", "Hiccup_001", "Hiccup_002", "Hiccup_003", "Hiccup_004", "Hiccup_005", "Hiccup_006", "Hiccup_007", "Hiccup_008", "Hiccup_009", "Hiccup_010", "Hiccup_011", "Hiccup_012", "Hiccup_013", "Hiccup_014", "Hiccup_015", "Hiccup_016", "Hiccup_017", "Hiccup_018", "Hiccup_019", "Hiccup_020", "Hiccup_021", "Hiccup_022", "Hiccup_023", "Hiccup_024", "Hiccup_025", "Hiccup_026", "Hiccup_027", "Hiccup_028", "Hiccup_029", "Hiccup_030", "Hiccup_031", "Hiccup_032", "Hiccup_033", "Hiccup_034", "Hiccup_035", "Hiccup_036", "Hiccup_037", "Hiccup_038", "Hiccup_039", "Hiccup_040", "Hiccup_041", "Hiccup_042", "Hiccup_043", "Hiccup_044", "Hiccup_045", "Hiccup_046", "Hiccup_047", "Hiccup_048", "Hiccup_049", "Hiccup_050", "Hiccup_051", "Hiccup_052", "Hiccup_053", "Hiccup_054"]),
            Book(
                id: "letstacoboutit",
                title: "Let's Taco 'Bout It",
                featured: true,
                free: true,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "mr taco"],
                littlebook: false,
                topRated: true,
                posterImage: "LetsTacoBoutIt",
                promoImage: "LetsTacoBoutIt_promo",
                details: "Mr Taco is feeling sad, it's not easy being a little taco when everything around you is so BIG!\n\nLuckily, Patrick has a few ideas to help his friend...",
                bookUrl: "https://www.boxfort.co/storybooks/lets-taco-bout-it",
                pages: [
                    "LetsTacoBoutIt_000", "LetsTacoBoutIt_001", "LetsTacoBoutIt_002", "LetsTacoBoutIt_003", "LetsTacoBoutIt_004", "LetsTacoBoutIt_005", "LetsTacoBoutIt_006", "LetsTacoBoutIt_007", "LetsTacoBoutIt_008", "LetsTacoBoutIt_009", "LetsTacoBoutIt_010", "LetsTacoBoutIt_011", "LetsTacoBoutIt_012", "LetsTacoBoutIt_013", "LetsTacoBoutIt_014", "LetsTacoBoutIt_015", "LetsTacoBoutIt_016", "LetsTacoBoutIt_017", "LetsTacoBoutIt_018", "LetsTacoBoutIt_019", "LetsTacoBoutIt_020", "LetsTacoBoutIt_021", "LetsTacoBoutIt_022", "LetsTacoBoutIt_023", "LetsTacoBoutIt_024", "LetsTacoBoutIt_025", "LetsTacoBoutIt_026", "LetsTacoBoutIt_027", "LetsTacoBoutIt_028", "LetsTacoBoutIt_029"]),
            Book(
                id: "penelopepineapple",
                title: "Penelope Pineapple (The Pineapple)",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["penelope pineapple"],
                littlebook: false,
                topRated: false,
                posterImage: "PenelopePineapple",
                promoImage: "PenelopePineapple_promo",
                details: "Pineapple was a pineapple. She looked like a pineapple, walked like a pineapple, talked like a pineapple, and played tennis like a pineapple. Until pineapple decided she wasn't just a pineapple any more. She was Penelope (the pineapple).",
                bookUrl: "https://www.boxfort.co/storybooks/penelope-pineapple",
                pages: [
                    "PenelopePineapple_000", "PenelopePineapple_001", "PenelopePineapple_002", "PenelopePineapple_003", "PenelopePineapple_004", "PenelopePineapple_005", "PenelopePineapple_006", "PenelopePineapple_007", "PenelopePineapple_008", "PenelopePineapple_009", "PenelopePineapple_010", "PenelopePineapple_011", "PenelopePineapple_012", "PenelopePineapple_013", "PenelopePineapple_014", "PenelopePineapple_015", "PenelopePineapple_016", "PenelopePineapple_017", "PenelopePineapple_018", "PenelopePineapple_019", "PenelopePineapple_020", "PenelopePineapple_021", "PenelopePineapple_022", "PenelopePineapple_023", "PenelopePineapple_024", "PenelopePineapple_025", "PenelopePineapple_026", "PenelopePineapple_027", "PenelopePineapple_028", "PenelopePineapple_029", "PenelopePineapple_030", "PenelopePineapple_031", "PenelopePineapple_032", "PenelopePineapple_033", "PenelopePineapple_034", "PenelopePineapple_035", "PenelopePineapple_036", "PenelopePineapple_037", "PenelopePineapple_038", "PenelopePineapple_039", "PenelopePineapple_040", "PenelopePineapple_041", "PenelopePineapple_042"]),
            Book(
                id: "theunhappyraincloud",
                title: "The Unhappy Rain Cloud",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "bennie the sloth"],
                littlebook: false,
                topRated: false,
                posterImage: "TheUnhappyRainCloud",
                promoImage: "TheUnhappyRainCloud_promo",
                details: "Another happy little story from BoxFort.",
                bookUrl: "https://www.boxfort.co/storybooks/the-unhappy-rain-cloud",
                pages: [
                    "TheUnhappyRainCloud_000", "TheUnhappyRainCloud_001", "TheUnhappyRainCloud_002", "TheUnhappyRainCloud_003", "TheUnhappyRainCloud_004", "TheUnhappyRainCloud_005", "TheUnhappyRainCloud_006", "TheUnhappyRainCloud_007", "TheUnhappyRainCloud_008", "TheUnhappyRainCloud_009", "TheUnhappyRainCloud_010", "TheUnhappyRainCloud_011", "TheUnhappyRainCloud_012", "TheUnhappyRainCloud_013", "TheUnhappyRainCloud_014", "TheUnhappyRainCloud_015", "TheUnhappyRainCloud_016", "TheUnhappyRainCloud_017", "TheUnhappyRainCloud_018", "TheUnhappyRainCloud_019", "TheUnhappyRainCloud_020", "TheUnhappyRainCloud_021", "TheUnhappyRainCloud_022", "TheUnhappyRainCloud_023", "TheUnhappyRainCloud_024", "TheUnhappyRainCloud_025"]),
            Book(
                id: "theniblit",
                title: "The Niblit",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "niblit"],
                littlebook: false,
                topRated: false,
                posterImage: "TheNiblit",
                promoImage: "TheNiblit_promo",
                details: "Have you ever met a Niblit?\n\nPatrick loves his pet Niblit, and he takes good care of it. If his Niblit needs to be walked, he will walk it (well, sort of), and if his Niblit wants a treat, Patrick is always ready with some Niblit-Nibbles. And if his Niblit wants its nose tickled, well then Patrick will tickle his Niblits nose...\n\nOnly problem is, tickling a Niblits nose can result in some very unexpected side effects!\n\nPatrick is going to need the help of a real expert to solve this tricky situation. A real Niblit expert. Someone with impeccable intellect. A sophisticated sort. Someone suave, dashing and handsome. Someone to take Patrick by the hand and guide him through this troubled time. Someone like...Dr Toast!",
                bookUrl: "https://www.boxfort.co/storybooks/the-unhappy-rain-cloud",
                pages: [
                    "TheNiblit_000", "TheNiblit_001", "TheNiblit_002", "TheNiblit_003", "TheNiblit_004", "TheNiblit_005", "TheNiblit_006", "TheNiblit_007", "TheNiblit_008", "TheNiblit_009", "TheNiblit_010", "TheNiblit_011", "TheNiblit_012", "TheNiblit_013", "TheNiblit_014", "TheNiblit_015", "TheNiblit_016", "TheNiblit_017", "TheNiblit_018", "TheNiblit_019", "TheNiblit_020", "TheNiblit_021", "TheNiblit_022", "TheNiblit_023", "TheNiblit_024"]),
            Book(
                id: "oneverybigniblit",
                title: "One Very Big Niblit",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "niblit", "dr toast"],
                littlebook: false,
                topRated: false,
                posterImage: "OneVeryBigNiblit",
                promoImage: "OneVeryBigNiblit_promo",
                details: "Have you ever met a Niblit?\n\nPatrick loves his pet Niblit, and he takes good care of it. If his Niblit needs to be walked, he will walk it (well, sort of), and if his Niblit wants a treat, Patrick is always ready with some Niblit-Nibbles. And if his Niblit wants its nose tickled, well then Patrick will tickle his Niblits nose...\n\nOnly problem is, tickling a Niblits nose can result in some very unexpected side effects!\n\nPatrick is going to need the help of a real expert to solve this tricky situation. A real Niblit expert. Someone with impeccable intellect. A sophisticated sort. Someone suave, dashing and handsome. Someone to take Patrick by the hand and guide him through this troubled time. Someone like...Dr Toast!",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "OneVeryBigNiblit_000", "OneVeryBigNiblit_001", "OneVeryBigNiblit_002", "OneVeryBigNiblit_003", "OneVeryBigNiblit_004", "OneVeryBigNiblit_005", "OneVeryBigNiblit_006", "OneVeryBigNiblit_007", "OneVeryBigNiblit_008", "OneVeryBigNiblit_009", "OneVeryBigNiblit_010", "OneVeryBigNiblit_011", "OneVeryBigNiblit_012", "OneVeryBigNiblit_013", "OneVeryBigNiblit_014", "OneVeryBigNiblit_015", "OneVeryBigNiblit_016", "OneVeryBigNiblit_017", "OneVeryBigNiblit_018", "OneVeryBigNiblit_019", "OneVeryBigNiblit_020", "OneVeryBigNiblit_021", "OneVeryBigNiblit_022", "OneVeryBigNiblit_023", "OneVeryBigNiblit_024", "OneVeryBigNiblit_025", "OneVeryBigNiblit_026", "OneVeryBigNiblit_027", "OneVeryBigNiblit_028", "OneVeryBigNiblit_029", "OneVeryBigNiblit_030", "OneVeryBigNiblit_031", "OneVeryBigNiblit_032", "OneVeryBigNiblit_033", "OneVeryBigNiblit_034", "OneVeryBigNiblit_035", "OneVeryBigNiblit_036", "OneVeryBigNiblit_037", "OneVeryBigNiblit_038", "OneVeryBigNiblit_039", "OneVeryBigNiblit_040", "OneVeryBigNiblit_041", "OneVeryBigNiblit_042", "OneVeryBigNiblit_043", "OneVeryBigNiblit_044", "OneVeryBigNiblit_045"]),
            Book(
                id: "thetreasuremap",
                title: "The Treasure Map",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "TheTreasureMap",
                promoImage: "TheTreasureMap_promo",
                details: "Another happy little story from BoxFort",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheTreasureMap_000", "TheTreasureMap_001", "TheTreasureMap_002", "TheTreasureMap_003", "TheTreasureMap_004", "TheTreasureMap_005", "TheTreasureMap_006", "TheTreasureMap_007", "TheTreasureMap_008", "TheTreasureMap_009", "TheTreasureMap_010", "TheTreasureMap_011", "TheTreasureMap_012", "TheTreasureMap_013", "TheTreasureMap_014", "TheTreasureMap_015", "TheTreasureMap_016", "TheTreasureMap_017", "TheTreasureMap_018", "TheTreasureMap_019", "TheTreasureMap_020", "TheTreasureMap_021", "TheTreasureMap_022", "TheTreasureMap_023", "TheTreasureMap_024", "TheTreasureMap_025", "TheTreasureMap_026", "TheTreasureMap_027", "TheTreasureMap_028", "TheTreasureMap_029", "TheTreasureMap_030", "TheTreasureMap_031", "TheTreasureMap_032", "TheTreasureMap_033", "TheTreasureMap_034"]),
            Book(
                id: "themove",
                title: "The Move",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "TheMove",
                promoImage: "TheMove_promo",
                details: "The same old Rubbish Town, the same old waffles. Arty is getting a little bit bored of the daily grind. He fancies a change.\n\nYes, Arty has made up his mind, he is leaving Rubbish Town! He's only going to pack the essentials - a toothbrush, a kite, some waffles, the kitchen sink...\n\nWill Arty really say his goodbyes to Rubbish Town? Read 'The Move' and find out.",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheMove_000", "TheMove_001", "TheMove_002", "TheMove_003", "TheMove_004", "TheMove_005", "TheMove_006", "TheMove_007", "TheMove_008", "TheMove_009", "TheMove_010", "TheMove_011", "TheMove_012", "TheMove_013", "TheMove_014", "TheMove_015", "TheMove_016", "TheMove_017", "TheMove_018", "TheMove_019", "TheMove_020", "TheMove_021", "TheMove_022", "TheMove_023", "TheMove_024", "TheMove_025", "TheMove_026"]),
            Book(
                id: "thehaircut",
                title: "The Haircut",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty", "marco"],
                littlebook: false,
                topRated: false,
                posterImage: "TheHaircut",
                promoImage: "TheHaircut_promo",
                details: "It might be time for a haircut Patrick...",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheHaircut_000", "TheHaircut_001", "TheHaircut_002", "TheHaircut_003", "TheHaircut_004", "TheHaircut_005", "TheHaircut_006", "TheHaircut_007", "TheHaircut_008", "TheHaircut_009", "TheHaircut_010", "TheHaircut_011", "TheHaircut_012", "TheHaircut_013", "TheHaircut_014", "TheHaircut_015", "TheHaircut_016", "TheHaircut_017", "TheHaircut_018", "TheHaircut_019", "TheHaircut_020", "TheHaircut_021", "TheHaircut_022", "TheHaircut_023", "TheHaircut_024", "TheHaircut_025", "TheHaircut_026", "TheHaircut_027", "TheHaircut_028", "TheHaircut_029", "TheHaircut_030", "TheHaircut_031", "TheHaircut_032", "TheHaircut_033", "TheHaircut_034", "TheHaircut_035", "TheHaircut_036", "TheHaircut_037", "TheHaircut_038"]),
            Book(
                id: "brave",
                title: "Brave",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "Brave",
                promoImage: "Brave_promo",
                details: "One brave adventurer! Battling dragons! Riding his steed! Protecting the castle! Kind of...",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "Brave_000", "Brave_001", "Brave_002", "Brave_003", "Brave_004", "Brave_005", "Brave_006", "Brave_007", "Brave_008", "Brave_009", "Brave_010"]),
            Book(
                id: "mytoesarecold",
                title: "My Toes Are Cold",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "perry the party polar bear"],
                littlebook: false,
                topRated: false,
                posterImage: "MyToesAreCold",
                promoImage: "MyToesAreCold_promo",
                details: "Another happy little story from BoxFort",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "MyToesAreCold_000", "MyToesAreCold_001", "MyToesAreCold_002", "MyToesAreCold_003", "MyToesAreCold_004", "MyToesAreCold_005", "MyToesAreCold_006", "MyToesAreCold_007", "MyToesAreCold_008", "MyToesAreCold_009", "MyToesAreCold_010", "MyToesAreCold_011", "MyToesAreCold_012", "MyToesAreCold_013", "MyToesAreCold_014", "MyToesAreCold_015", "MyToesAreCold_016", "MyToesAreCold_017", "MyToesAreCold_018", "MyToesAreCold_019", "MyToesAreCold_020", "MyToesAreCold_021", "MyToesAreCold_022", "MyToesAreCold_023", "MyToesAreCold_024", "MyToesAreCold_025", "MyToesAreCold_026", "MyToesAreCold_027", "MyToesAreCold_028"]),
            Book(
                id: "thestoppedclock",
                title: "The Stopped Clock",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "bobbins the baker", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "TheStoppedClock",
                promoImage: "TheStoppedClock_promo",
                details: "The Rubbish Town clock has stopped and now all the residents have overslept!/nIt's up to Patrick to fix the clock and save the town - he's tried turning the cogs, he's tried chewing the cogs, he's even tried taking one of the cogs for a walk…nothing is working!\n\nCome help Patrick save Rubbish Town",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheStoppedClock_000", "TheStoppedClock_001", "TheStoppedClock_002", "TheStoppedClock_003", "TheStoppedClock_004", "TheStoppedClock_005", "TheStoppedClock_006", "TheStoppedClock_007", "TheStoppedClock_008", "TheStoppedClock_009", "TheStoppedClock_010", "TheStoppedClock_011", "TheStoppedClock_012", "TheStoppedClock_013", "TheStoppedClock_014", "TheStoppedClock_015", "TheStoppedClock_016", "TheStoppedClock_017", "TheStoppedClock_018", "TheStoppedClock_019", "TheStoppedClock_020", "TheStoppedClock_021", "TheStoppedClock_022", "TheStoppedClock_023", "TheStoppedClock_024", "TheStoppedClock_025", "TheStoppedClock_026", "TheStoppedClock_027", "TheStoppedClock_028", "TheStoppedClock_029", "TheStoppedClock_030", "TheStoppedClock_031", "TheStoppedClock_032", "TheStoppedClock_033", "TheStoppedClock_034", "TheStoppedClock_035", "TheStoppedClock_036", "TheStoppedClock_037", "TheStoppedClock_038", "TheStoppedClock_039", "TheStoppedClock_040", "TheStoppedClock_041", "TheStoppedClock_042", "TheStoppedClock_043", "TheStoppedClock_044"]),
            Book(
                id: "theeloquentpenguin",
                title: "The Eloquent Penguin",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["professor penguin", "the eloquent penguin"],
                littlebook: false,
                topRated: false,
                posterImage: "TheEloquentPenguin",
                promoImage: "TheEloquentPenguin_promo",
                details: "We meet one of Professor Penguin's dearest friend: The Eloquent Penguin. He has such a wonderful way with words...unfortunately, Professor Penguin has no idea what most of those words mean!",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheEloquentPenguin_000", "TheEloquentPenguin_001", "TheEloquentPenguin_002", "TheEloquentPenguin_003", "TheEloquentPenguin_004", "TheEloquentPenguin_005", "TheEloquentPenguin_006", "TheEloquentPenguin_007", "TheEloquentPenguin_008", "TheEloquentPenguin_009", "TheEloquentPenguin_010", "TheEloquentPenguin_011", "TheEloquentPenguin_012", "TheEloquentPenguin_013", "TheEloquentPenguin_014", "TheEloquentPenguin_015", "TheEloquentPenguin_016", "TheEloquentPenguin_017", "TheEloquentPenguin_018", "TheEloquentPenguin_019", "TheEloquentPenguin_020", "TheEloquentPenguin_021", "TheEloquentPenguin_022", "TheEloquentPenguin_023", "TheEloquentPenguin_024", "TheEloquentPenguin_025", "TheEloquentPenguin_026"]),
            Book(
                id: "patrickfoundasomething",
                title: "Patrick Found A Something",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "PatrickFoundASomething",
                promoImage: "PatrickFoundASomething_promo",
                details: "Patrick has found something special. But what is it? It isn't very good at doing the dishes. And it doesn't taste very good either.",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "PatrickFoundASomething_000", "PatrickFoundASomething_001", "PatrickFoundASomething_002", "PatrickFoundASomething_003", "PatrickFoundASomething_004", "PatrickFoundASomething_005", "PatrickFoundASomething_006", "PatrickFoundASomething_007", "PatrickFoundASomething_008", "PatrickFoundASomething_009", "PatrickFoundASomething_010", "PatrickFoundASomething_011", "PatrickFoundASomething_012", "PatrickFoundASomething_013", "PatrickFoundASomething_014", "PatrickFoundASomething_015", "PatrickFoundASomething_016", "PatrickFoundASomething_017", "PatrickFoundASomething_018", "PatrickFoundASomething_019", "PatrickFoundASomething_020", "PatrickFoundASomething_021", "PatrickFoundASomething_022"]),
            Book(
                id: "HuffAndPuff",
                title: "Huff & Puff",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "HuffAndPuff",
                promoImage: "HuffAndPuff_promo",
                details: "Patrick finds a cloud who has fallen out of the sky. Can he get the little cloud back home?",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "HuffAndPuff_000", "HuffAndPuff_001", "HuffAndPuff_002", "HuffAndPuff_003", "HuffAndPuff_004", "HuffAndPuff_005", "HuffAndPuff_006", "HuffAndPuff_007", "HuffAndPuff_008", "HuffAndPuff_009", "HuffAndPuff_010", "HuffAndPuff_011", "HuffAndPuff_012", "HuffAndPuff_013", "HuffAndPuff_014", "HuffAndPuff_015", "HuffAndPuff_016"]),
            Book(
                id: "artycantsleep",
                title: "Arty Can't Sleep",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["arty"],
                littlebook: false,
                topRated: false,
                posterImage: "ArtyCantSleep",
                promoImage: "ArtyCantSleep_promo",
                details: "Arty can't sleep",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "ArtyCantSleep_000", "ArtyCantSleep_001", "ArtyCantSleep_002", "ArtyCantSleep_003", "ArtyCantSleep_004", "ArtyCantSleep_005", "ArtyCantSleep_006", "ArtyCantSleep_007", "ArtyCantSleep_008", "ArtyCantSleep_009", "ArtyCantSleep_010", "ArtyCantSleep_011", "ArtyCantSleep_012", "ArtyCantSleep_013", "ArtyCantSleep_014", "ArtyCantSleep_015", "ArtyCantSleep_016", "ArtyCantSleep_017", "ArtyCantSleep_018", "ArtyCantSleep_019", "ArtyCantSleep_020", "ArtyCantSleep_021", "ArtyCantSleep_022", "ArtyCantSleep_023", "ArtyCantSleep_024", "ArtyCantSleep_025", "ArtyCantSleep_026", "ArtyCantSleep_027", "ArtyCantSleep_028", "ArtyCantSleep_029", "ArtyCantSleep_030", "ArtyCantSleep_031", "ArtyCantSleep_032"]),
            Book(
                id: "justbecause",
                title: "Just Because",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "JustBecause",
                promoImage: "JustBecause_promo",
                details: "Kevin is a very clever little monster, he always knows the answers to all of Arty's questions. Which is a very good thing since Arty has so very many questions to ask!",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "JustBecause_000", "JustBecause_001", "JustBecause_002", "JustBecause_003", "JustBecause_004", "JustBecause_005", "JustBecause_006", "JustBecause_007", "JustBecause_008", "JustBecause_009", "JustBecause_010", "JustBecause_011", "JustBecause_012", "JustBecause_013", "JustBecause_014", "JustBecause_015", "JustBecause_016", "JustBecause_017", "JustBecause_018", "JustBecause_019", "JustBecause_020", "JustBecause_021"]),
            Book(
                id: "patricktakesoff",
                title: "Patrick Takes Off",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "PatrickTakesOff",
                promoImage: "PatrickTakesOff_promo",
                details: "Ever since Patrick was a very, very little monster, he has wanted to visit space! He would talk about it at breakfast, he would talk about it at lunchtime, he would talk about it at diner time, and sometimes he would even talk about it in his sleep!\n\nWell, enough talking. Patrick has decided he is going to go to space.\n\nToday.",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "PatrickTakesOff_000", "PatrickTakesOff_001", "PatrickTakesOff_002", "PatrickTakesOff_003", "PatrickTakesOff_004", "PatrickTakesOff_005", "PatrickTakesOff_006", "PatrickTakesOff_007", "PatrickTakesOff_008", "PatrickTakesOff_009", "PatrickTakesOff_010", "PatrickTakesOff_011", "PatrickTakesOff_012", "PatrickTakesOff_013", "PatrickTakesOff_014", "PatrickTakesOff_015", "PatrickTakesOff_016", "PatrickTakesOff_017", "PatrickTakesOff_018", "PatrickTakesOff_019", "PatrickTakesOff_020", "PatrickTakesOff_021", "PatrickTakesOff_022", "PatrickTakesOff_023", "PatrickTakesOff_024", "PatrickTakesOff_025", "PatrickTakesOff_026", "PatrickTakesOff_027", "PatrickTakesOff_028", "PatrickTakesOff_029", "PatrickTakesOff_030", "PatrickTakesOff_031", "PatrickTakesOff_032", "PatrickTakesOff_033", "PatrickTakesOff_034", "PatrickTakesOff_035", "PatrickTakesOff_036", "PatrickTakesOff_037", "PatrickTakesOff_038", "PatrickTakesOff_039", "PatrickTakesOff_040", "PatrickTakesOff_041", "PatrickTakesOff_042", "PatrickTakesOff_043", "PatrickTakesOff_044", "PatrickTakesOff_045", "PatrickTakesOff_046", "PatrickTakesOff_047", "PatrickTakesOff_048", "PatrickTakesOff_049", "PatrickTakesOff_050", "PatrickTakesOff_051", "PatrickTakesOff_052", "PatrickTakesOff_053", "PatrickTakesOff_054", "PatrickTakesOff_055", "PatrickTakesOff_056", "PatrickTakesOff_057", "PatrickTakesOff_058"]),
            Book(
                id: "somethingtodowithpumpkins",
                title: "Something to do with Pumpkins",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: false,
                posterImage: "SomethingToDoWithPumpkins",
                promoImage: "SomethingToDoWithPumpkins_promo",
                details: "Kevin has just returned from a trip to a far, far away land. A land where October was a very special month indeed.\n\nPumpkins were everywhere, and people were dressing up and getting free candy!\n\nPatrick couldn't believe it - free candy! He had to get in on this...\n\nEnjoy this very special Halloween edition of Patrick, Kevin & Arty from BoxFort\n\nHappy Halloween!",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "SomethingToDoWithPumpkins_000", "SomethingToDoWithPumpkins_001", "SomethingToDoWithPumpkins_002", "SomethingToDoWithPumpkins_003", "SomethingToDoWithPumpkins_004", "SomethingToDoWithPumpkins_005", "SomethingToDoWithPumpkins_006", "SomethingToDoWithPumpkins_007", "SomethingToDoWithPumpkins_008", "SomethingToDoWithPumpkins_009", "SomethingToDoWithPumpkins_010", "SomethingToDoWithPumpkins_011", "SomethingToDoWithPumpkins_012", "SomethingToDoWithPumpkins_013", "SomethingToDoWithPumpkins_014", "SomethingToDoWithPumpkins_015", "SomethingToDoWithPumpkins_016", "SomethingToDoWithPumpkins_017", "SomethingToDoWithPumpkins_018", "SomethingToDoWithPumpkins_019", "SomethingToDoWithPumpkins_020", "SomethingToDoWithPumpkins_021", "SomethingToDoWithPumpkins_022", "SomethingToDoWithPumpkins_023", "SomethingToDoWithPumpkins_024", "SomethingToDoWithPumpkins_025", "SomethingToDoWithPumpkins_026", "SomethingToDoWithPumpkins_027", "SomethingToDoWithPumpkins_028"]),
            
            Book(
                id: "patrickvscake",
                title: "Patrick vs Cake",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "PatrickVsCake",
                promoImage: "PatrickVsCake_promo",
                details: "Patrick has visited his friend Arty's house. Arty isn't home, but a giant delicious cake is. Can Patrick resist?",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "PatrickVsCake_000", "PatrickVsCake_001", "PatrickVsCake_002", "PatrickVsCake_003", "PatrickVsCake_004", "PatrickVsCake_005", "PatrickVsCake_006", "PatrickVsCake_007", "PatrickVsCake_008", "PatrickVsCake_009", "PatrickVsCake_010", "PatrickVsCake_011", "PatrickVsCake_012", "PatrickVsCake_013"]),
           
            /*
            Book(
                title: "The Only Explanation",
                id: "TheOnlyExplanation",
                featured: false,
                free: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "dr toast", "president bunny mcbunnyface"],
                littlebook: true,
                topRated: false,
                posterImage: "TheOnlyExplanation",
                promoImage: "TheOnlyExplanation_promo",
                details: "Patrick has lost his other sock! There must be a sock thief on the loose, it's the only explanation...",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "TheOnlyExplanation_000", "TheOnlyExplanation_001", "TheOnlyExplanation_002", "TheOnlyExplanation_003", "TheOnlyExplanation_004", "TheOnlyExplanation_005", "TheOnlyExplanation_006", "TheOnlyExplanation_007", "TheOnlyExplanation_008", "TheOnlyExplanation_009", "TheOnlyExplanation_010"]),
             */
            /*
            Book(
                title: "Tag",
                id: "Tag",
                featured: false,
                free: false,
                new: false,
                characters: ["patrick", "arty"],
                littlebook: true,
                topRated: false,
                posterImage: "Tag",
                promoImage: "Tag_promo",
                details: "Patrick is on an epic journey. He will travel far, he will travel wide. He has to get to where he is going!\n\nBut what is it that has Patrick so determined?",
                bookUrl: "https://www.boxfort.co/storybooks/one-very-big-niblit",
                pages: [
                    "Tag_000", "Tag_001", "Tag_002", "Tag_003", "Tag_004", "Tag_005", "Tag_006", "Tag_007", "Tag_008", "Tag_009", "Tag_010", "Tag_011"]),
            */


        ]
    }
}

