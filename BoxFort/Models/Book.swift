//
//  Book.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  Book.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let featured: Bool
    let free: Bool
    var isPurchased: Bool
    let new: Bool
    let characters: [String]
    let littlebook: Bool
    let topRated: Bool
    let posterImage: String
    let promoImage: String
    let details: String
    let bookUrl: String
    let pages: [String]
    
    // Co-reading properties
    var activeCoReadingSession: CoReadingSession?
    var allowsCoReading: Bool = true
    
    // Preview properties
    var previewPages: Int {
        return max(1, Int(Double(pages.count) * 0.1)) // 10% of pages, minimum 1
    }
    
    var displayPrice: String {
        String(format: "$%.2f", price)
    }
    
    // Computed property for price - free books are 0.0, paid books are 4.99
    var price: Double {
        free ? 0.0 : 4.99
    }
    
    // Computed property that returns the id with only alpha characters, lowercase
    var productId: String {
        return id.lowercased().filter { $0.isLetter }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case featured
        case free
        case isPurchased
        case new
        case characters
        case littlebook
        case topRated
        case posterImage
        case promoImage
        case details
        case bookUrl
        case pages
        case allowsCoReading
    }
    
    init(id: String, title: String, featured: Bool, free: Bool, isPurchased: Bool = false, new: Bool = false, characters: [String] = [], littlebook: Bool = false, topRated: Bool = false, posterImage: String = "", promoImage: String = "", details: String = "", bookUrl: String = "", pages: [String] = [], allowsCoReading: Bool = true) {
        self.id = id
        self.title = title
        self.featured = featured
        self.free = free
        self.isPurchased = isPurchased
        self.new = new
        self.characters = characters
        self.littlebook = littlebook
        self.topRated = topRated
        self.posterImage = posterImage
        self.promoImage = promoImage
        self.details = details
        self.bookUrl = bookUrl
        self.pages = pages
        self.allowsCoReading = allowsCoReading
        self.activeCoReadingSession = nil
    }

    static var sampleBooks: [Book] {
        return BookSection.sampleBooks
    }
    
    static var promos: [Book] {
        return sampleBooks.filter { $0.featured }
    }
}

extension Book {
    static var patFeat: [Book] {
        return [
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
                bookUrl: "https://www.boxfort.co/storybooks/sports-day",
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
                bookUrl: "https://www.boxfort.co/storybooks/the-box-animated",
                pages: [
                    "TheBox_000", "TheBox_001", "TheBox_002", "TheBox_003", "TheBox_004", "TheBox_005", "TheBox_006", "TheBox_007", "TheBox_008", "TheBox_009", "TheBox_010", "TheBox_011", "TheBox_012", "TheBox_013", "TheBox_014", "TheBox_015", "TheBox_016", "TheBox_017", "TheBox_018", "TheBox_019", "TheBox_020", "TheBox_021", "TheBox_022", "TheBox_023", "TheBox_024", "TheBox_025", "TheBox_026"]),
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
                bookUrl: "https://www.boxfort.co/storybooks/the-expert",
                pages: [
                    "TheExpert_000", "TheExpert_001", "TheExpert_002", "TheExpert_003", "TheExpert_004", "TheExpert_005", "TheExpert_006", "TheExpert_007", "TheExpert_008", "TheExpert_009", "TheExpert_010", "TheExpert_011", "TheExpert_012", "TheExpert_013", "TheExpert_014", "TheExpert_015", "TheExpert_016", "TheExpert_017", "TheExpert_018", "TheExpert_019", "TheExpert_020", "TheExpert_021", "TheExpert_022", "TheExpert_023", "TheExpert_024", "TheExpert_025", "TheExpert_026"]),
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
                bookUrl: "https://www.boxfort.co/storybooks/nothing-to-worry-about",
                pages: [
                    "NothingToWorryAbout_000", "NothingToWorryAbout_001", "NothingToWorryAbout_002", "NothingToWorryAbout_003", "NothingToWorryAbout_004", "NothingToWorryAbout_005", "NothingToWorryAbout_006", "NothingToWorryAbout_007", "NothingToWorryAbout_008", "NothingToWorryAbout_009", "NothingToWorryAbout_010", "NothingToWorryAbout_011", "NothingToWorryAbout_012", "NothingToWorryAbout_013", "NothingToWorryAbout_014", "NothingToWorryAbout_015", "NothingToWorryAbout_016", "NothingToWorryAbout_017", "NothingToWorryAbout_018", "NothingToWorryAbout_019", "NothingToWorryAbout_020", "NothingToWorryAbout_021", "NothingToWorryAbout_022", "NothingToWorryAbout_023", "NothingToWorryAbout_024", "NothingToWorryAbout_025", "NothingToWorryAbout_026", "NothingToWorryAbout_027", "NothingToWorryAbout_028", "NothingToWorryAbout_029", "NothingToWorryAbout_030", "NothingToWorryAbout_031", "NothingToWorryAbout_032", "NothingToWorryAbout_033", "NothingToWorryAbout_034", "NothingToWorryAbout_035", "NothingToWorryAbout_036", "NothingToWorryAbout_037", "NothingToWorryAbout_038", "NothingToWorryAbout_039", "NothingToWorryAbout_040", "NothingToWorryAbout_041", "NothingToWorryAbout_042", "NothingToWorryAbout_043", "NothingToWorryAbout_044", "NothingToWorryAbout_045", "NothingToWorryAbout_046", "NothingToWorryAbout_047", "NothingToWorryAbout_048", "NothingToWorryAbout_049", "NothingToWorryAbout_050", "NothingToWorryAbout_051"]),
        ]
    }
    static var artyFeat: [Book] {
        return [
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
                bookUrl: "https://www.boxfort.co/storybooks/the-box-animated",
                pages: [
                    "TheBox_000", "TheBox_001", "TheBox_002", "TheBox_003", "TheBox_004", "TheBox_005", "TheBox_006", "TheBox_007", "TheBox_008", "TheBox_009", "TheBox_010", "TheBox_011", "TheBox_012", "TheBox_013", "TheBox_014", "TheBox_015", "TheBox_016", "TheBox_017", "TheBox_018", "TheBox_019", "TheBox_020", "TheBox_021", "TheBox_022", "TheBox_023", "TheBox_024", "TheBox_025", "TheBox_026"]),
            Book(
                id: "thebigblueberry",
                title: "The Big Blueberry",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: true,
                posterImage: "TheBigBlueberry",
                promoImage: "TheBigBlueberry_promo",
                details: "Arty is busy in his garden planting some new seeds. He has some delightful carrots and some lovely tomatoes, and even a super special secret seed! What could this mysterious seed grow to be?\n\nAnd what will Patrick make of it all?",
                bookUrl: "https://www.boxfort.co/storybooks/the-big-blueberry",
                pages: [
                    "TheBigBlueberry_000", "TheBigBlueberry_001", "TheBigBlueberry_002", "TheBigBlueberry_003", "TheBigBlueberry_004", "TheBigBlueberry_005", "TheBigBlueberry_006", "TheBigBlueberry_007", "TheBigBlueberry_008", "TheBigBlueberry_009", "TheBigBlueberry_010", "TheBigBlueberry_011", "TheBigBlueberry_012", "TheBigBlueberry_013", "TheBigBlueberry_014", "TheBigBlueberry_015", "TheBigBlueberry_016", "TheBigBlueberry_017", "TheBigBlueberry_018", "TheBigBlueberry_019", "TheBigBlueberry_020", "TheBigBlueberry_021", "TheBigBlueberry_022", "TheBigBlueberry_023", "TheBigBlueberry_024", "TheBigBlueberry_025", "TheBigBlueberry_026", "TheBigBlueberry_027", "TheBigBlueberry_028"]),
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
                bookUrl: "https://www.boxfort.co/storybooks/an-arty-for-all-seasons",
                pages: [
                    "AnArtyForAllSeasons_000", "AnArtyForAllSeasons_001", "AnArtyForAllSeasons_002", "AnArtyForAllSeasons_003", "AnArtyForAllSeasons_004", "AnArtyForAllSeasons_005", "AnArtyForAllSeasons_006", "AnArtyForAllSeasons_007", "AnArtyForAllSeasons_008", "AnArtyForAllSeasons_009", "AnArtyForAllSeasons_010", "AnArtyForAllSeasons_011", "AnArtyForAllSeasons_012", "AnArtyForAllSeasons_013", "AnArtyForAllSeasons_014", "AnArtyForAllSeasons_015", "AnArtyForAllSeasons_016", "AnArtyForAllSeasons_017", "AnArtyForAllSeasons_018", "AnArtyForAllSeasons_019", "AnArtyForAllSeasons_020", "AnArtyForAllSeasons_021", "AnArtyForAllSeasons_022", "AnArtyForAllSeasons_023", "AnArtyForAllSeasons_024", "AnArtyForAllSeasons_025", "AnArtyForAllSeasons_026", "AnArtyForAllSeasons_027", "AnArtyForAllSeasons_028", "AnArtyForAllSeasons_029", "AnArtyForAllSeasons_030", "AnArtyForAllSeasons_031", "AnArtyForAllSeasons_032", "AnArtyForAllSeasons_033"]),
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
                bookUrl: "https://www.boxfort.co/storybooks/hiccup",
                pages: [
                    "Hiccup_000", "Hiccup_001", "Hiccup_002", "Hiccup_003", "Hiccup_004", "Hiccup_005", "Hiccup_006", "Hiccup_007", "Hiccup_008", "Hiccup_009", "Hiccup_010", "Hiccup_011", "Hiccup_012", "Hiccup_013", "Hiccup_014", "Hiccup_015", "Hiccup_016", "Hiccup_017", "Hiccup_018", "Hiccup_019", "Hiccup_020", "Hiccup_021", "Hiccup_022", "Hiccup_023", "Hiccup_024", "Hiccup_025", "Hiccup_026", "Hiccup_027", "Hiccup_028", "Hiccup_029", "Hiccup_030", "Hiccup_031", "Hiccup_032", "Hiccup_033", "Hiccup_034", "Hiccup_035", "Hiccup_036", "Hiccup_037", "Hiccup_038", "Hiccup_039", "Hiccup_040", "Hiccup_041", "Hiccup_042", "Hiccup_043", "Hiccup_044", "Hiccup_045", "Hiccup_046", "Hiccup_047", "Hiccup_048", "Hiccup_049", "Hiccup_050", "Hiccup_051", "Hiccup_052", "Hiccup_053", "Hiccup_054"]),
        ]
    }
    static var kevFeat: [Book] {
        return [
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
                bookUrl: "https://www.boxfort.co/storybooks/a-very-hairy-little-monster",
                pages: [
                    "AVeryHairyLittleMonster_000", "AVeryHairyLittleMonster_001", "AVeryHairyLittleMonster_002", "AVeryHairyLittleMonster_003", "AVeryHairyLittleMonster_004", "AVeryHairyLittleMonster_005", "AVeryHairyLittleMonster_006", "AVeryHairyLittleMonster_007", "AVeryHairyLittleMonster_008", "AVeryHairyLittleMonster_009", "AVeryHairyLittleMonster_010", "AVeryHairyLittleMonster_011", "AVeryHairyLittleMonster_012", "AVeryHairyLittleMonster_013", "AVeryHairyLittleMonster_014", "AVeryHairyLittleMonster_015", "AVeryHairyLittleMonster_016", "AVeryHairyLittleMonster_017", "AVeryHairyLittleMonster_018", "AVeryHairyLittleMonster_019", "AVeryHairyLittleMonster_020", "AVeryHairyLittleMonster_021", "AVeryHairyLittleMonster_022", "AVeryHairyLittleMonster_023", "AVeryHairyLittleMonster_024", "AVeryHairyLittleMonster_025", "AVeryHairyLittleMonster_026", "AVeryHairyLittleMonster_027", "AVeryHairyLittleMonster_028", "AVeryHairyLittleMonster_029", "AVeryHairyLittleMonster_030", "AVeryHairyLittleMonster_031", "AVeryHairyLittleMonster_032", "AVeryHairyLittleMonster_033", "AVeryHairyLittleMonster_034", "AVeryHairyLittleMonster_035", "AVeryHairyLittleMonster_036", "AVeryHairyLittleMonster_037", "AVeryHairyLittleMonster_038", "AVeryHairyLittleMonster_039", "AVeryHairyLittleMonster_040", "AVeryHairyLittleMonster_041", "AVeryHairyLittleMonster_042", "AVeryHairyLittleMonster_043", "AVeryHairyLittleMonster_044", "AVeryHairyLittleMonster_045"]),
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
                id: "thecaseofthemissingbanana",
                title: "The Case of the Missing Banana",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "arty", "kevin"],
                littlebook: false,
                topRated: true,
                posterImage: "TheCaseOfTheMissingBanana",
                promoImage: "TheCaseOfTheMissingBanana_promo",
                details: "Someone has stolen Patrick's banana! But with the help of his friends Kevin and Arty, he's set out to track down his missing fruit (and the cowardly thief who took it).\n\nIt's up to Kevin and Arty to play detective to find out where the banana might be. Maybe it was taken while Patrick was playing soccer? Or while Patrick was reading a book? Perhaps it happened when Patrick went in to the kitchen and ate a banana.\n\nWait a minute...",
                bookUrl: "https://www.boxfort.co/storybooks/sports-day",
                pages: [
                    "TheCaseOfTheMissingBanana_000", "TheCaseOfTheMissingBanana_001", "TheCaseOfTheMissingBanana_002", "TheCaseOfTheMissingBanana_003", "TheCaseOfTheMissingBanana_004", "TheCaseOfTheMissingBanana_005", "TheCaseOfTheMissingBanana_006", "TheCaseOfTheMissingBanana_007", "TheCaseOfTheMissingBanana_008", "TheCaseOfTheMissingBanana_009", "TheCaseOfTheMissingBanana_010", "TheCaseOfTheMissingBanana_011", "TheCaseOfTheMissingBanana_012", "TheCaseOfTheMissingBanana_013", "TheCaseOfTheMissingBanana_014", "TheCaseOfTheMissingBanana_015", "TheCaseOfTheMissingBanana_016", "TheCaseOfTheMissingBanana_017", "TheCaseOfTheMissingBanana_018", "TheCaseOfTheMissingBanana_019", "TheCaseOfTheMissingBanana_020", "TheCaseOfTheMissingBanana_021", "TheCaseOfTheMissingBanana_022", "TheCaseOfTheMissingBanana_023", "TheCaseOfTheMissingBanana_024", "TheCaseOfTheMissingBanana_025", "TheCaseOfTheMissingBanana_026", "TheCaseOfTheMissingBanana_027", "TheCaseOfTheMissingBanana_028", "TheCaseOfTheMissingBanana_029", "TheCaseOfTheMissingBanana_030", "TheCaseOfTheMissingBanana_031", "TheCaseOfTheMissingBanana_032", "TheCaseOfTheMissingBanana_033", "TheCaseOfTheMissingBanana_034", "TheCaseOfTheMissingBanana_035"]),
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
            
        ]
    }
    static var videoStory: [Book] {
        return [
            
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
                id: "TheExpert",
                title: "The Expert",
                featured: true,
                free: false,
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
             /*
            Book(
                id: "TheImpossibleDoor",
                title: "The Impossible Door",
                featured: false,
                free: false,
                new: false,
                characters: ["patrick", "kevin", "arty", "dr toast"],
                littlebook: false,
                topRated: true,
                posterImage: "TheImpossibleDoor",
                promoImage: "TheImpossibleDoor_promo",
                details: "Patrick has just brought home his very heavy shopping bags and is looking forward to a delicious waffle-jam sandwich.\n\nThere's just one problem - Patrick can't seem to open his front door!",
                bookUrl: "https://www.boxfort.co",
                pages: [
                    "TheImpossibleDoor_000", "TheImpossibleDoor_001", "TheImpossibleDoor_002", "TheImpossibleDoor_003", "TheImpossibleDoor_004", "TheImpossibleDoor_005", "TheImpossibleDoor_006", "TheImpossibleDoor_007", "TheImpossibleDoor_008", "TheImpossibleDoor_009", "TheImpossibleDoor_010", "TheImpossibleDoor_011", "TheImpossibleDoor_012", "TheImpossibleDoor_013", "TheImpossibleDoor_014", "TheImpossibleDoor_015", "TheImpossibleDoor_016", "TheImpossibleDoor_017", "TheImpossibleDoor_018", "TheImpossibleDoor_019", "TheImpossibleDoor_020", "TheImpossibleDoor_021", "TheImpossibleDoor_022", "TheImpossibleDoor_023", "TheImpossibleDoor_024", "TheImpossibleDoor_025"]),
            */
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
                id: "thebigblueberry",
                title: "The Big Blueberry",
                featured: false,
                free: false,
                isPurchased: false,
                new: false,
                characters: ["patrick", "kevin", "arty"],
                littlebook: false,
                topRated: true,
                posterImage: "TheBigBlueberry",
                promoImage: "TheBigBlueberry_promo",
                details: "Arty is busy in his garden planting some new seeds. He has some delightful carrots and some lovely tomatoes, and even a super special secret seed! What could this mysterious seed grow to be?\n\nAnd what will Patrick make of it all?",
                bookUrl: "TheBigBlueberry.mp4",
                pages: [
                    "TheBigBlueberry_000", "TheBigBlueberry_001", "TheBigBlueberry_002", "TheBigBlueberry_003", "TheBigBlueberry_004", "TheBigBlueberry_005", "TheBigBlueberry_006", "TheBigBlueberry_007", "TheBigBlueberry_008", "TheBigBlueberry_009", "TheBigBlueberry_010", "TheBigBlueberry_011", "TheBigBlueberry_012", "TheBigBlueberry_013", "TheBigBlueberry_014", "TheBigBlueberry_015", "TheBigBlueberry_016", "TheBigBlueberry_017", "TheBigBlueberry_018", "TheBigBlueberry_019", "TheBigBlueberry_020", "TheBigBlueberry_021", "TheBigBlueberry_022", "TheBigBlueberry_023", "TheBigBlueberry_024", "TheBigBlueberry_025", "TheBigBlueberry_026", "TheBigBlueberry_027", "TheBigBlueberry_028"]),
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
            
            ]
    }
}


