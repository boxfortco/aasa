// BoxFort S3 Image System
// Uses your existing S3 bucket: https://boxfort-storybooks.s3.us-east-2.amazonaws.com/
// Structure: [BOOK NAME]/[PAGE NAME] with automatic extension detection

const S3_BASE_URL = 'https://boxfort-storybooks.s3.us-east-2.amazonaws.com';
const EXTENSIONS = ['.jpg', '.png', '.gif']; // Try these extensions in order

// Book metadata mapping
const bookMetadata = {
    'anartyforallseasons': { title: 'An Arty For All Seasons', folder: 'AnArtyForAllSeasons' },
    'artwork': { title: 'Artwork', folder: 'Artwork' },
    'artycantsleep': { title: 'Arty Can\'t Sleep', folder: 'ArtyCantSleep' },
    'aspotofbother': { title: 'A Spot of Bother', folder: 'ASpotOfBother' },
    'averyhairylittlemonster': { title: 'A Very Hairy Little Monster', folder: 'AVeryHairyLittleMonster' },
    'bigfish': { title: 'Big Fish', folder: 'BigFish' },
    'bigscarymonsters': { title: 'Big Scary Monsters', folder: 'BigScaryMonsters' },
    'brave': { title: 'Brave', folder: 'Brave' },
    'bubblegum': { title: 'Bubblegum', folder: 'Bubblegum' },
    'caketastrophe': { title: 'Caketastrophe', folder: 'Caketastrophe' },
    'chaosterror': { title: 'Chaos Terror Marshmallows', folder: 'ChaosTerrorMarshmallows' },
    'costumeparty': { title: 'Costume Party', folder: 'CostumeParty' },
    'fireworks': { title: 'Fireworks', folder: 'Fireworks' },
    'followthatduck': { title: 'Follow That Duck', folder: 'FollowThatDuck' },
    'footprints': { title: 'Footprints', folder: 'Footprints' },
    'forgetmenot': { title: 'Forget Me Not', folder: 'ForgetMeNot' },
    'hiccup': { title: 'Hiccup', folder: 'Hiccup' },
    'housesit': { title: 'House Sit', folder: 'HouseSit' },
    'huffandpuff': { title: 'Huff and Puff', folder: 'HuffAndPuff' },
    'justbecause': { title: 'Just Because', folder: 'JustBecause' },
    'letstacoboutit': { title: 'Let\'s Taco Bout It', folder: 'LetsTacoBoutIt' },
    'lost': { title: 'Lost', folder: 'Lost' },
    'measuringup': { title: 'Measuring Up', folder: 'MeasuringUp' },
    'mytoesarecold': { title: 'My Toes Are Cold', folder: 'MyToesAreCold' },
    'nothingtoworryabout': { title: 'Nothing To Worry About', folder: 'NothingToWorryAbout' },
    'onemorething': { title: 'One More Thing', folder: 'OneMoreThing' },
    'oneverybigniblit': { title: 'One Very Big Niblit', folder: 'OneVeryBigNiblit' },
    'patrickfoundasomething': { title: 'Patrick Found A Something', folder: 'PatrickFoundASomething' },
    'patricktakesoff': { title: 'Patrick Takes Off', folder: 'PatrickTakesOff' },
    'patrickvscake': { title: 'Patrick Vs Cake', folder: 'PatrickVsCake' },
    'penelopepineapple': { title: 'Penelope Pineapple', folder: 'PenelopePineapple' },
    'somethingtodowithpumpkins': { title: 'Something To Do With Pumpkins', folder: 'SomethingToDoWithPumpkins' },
    'sportsday': { title: 'Sports Day', folder: 'SportsDay' },
    'stakeout': { title: 'Stake Out', folder: 'StakeOut' },
    'surprise': { title: 'Surprise', folder: 'Surprise' },
    'sheepover': { title: 'Sheep Over', folder: 'SheepOver' },
    'earworm': { title: 'Earworm', folder: 'Earworm' },
    'colonelgooseberry': { title: 'Colonel Gooseberry and the Raiders of the New Light', folder: 'ColonelGooseberry' },
    'taconauts': { title: 'Taconauts', folder: 'Taconauts' },
    'tag': { title: 'Tag', folder: 'Tag' },
    'thebigblueberry': { title: 'The Big Blueberry', folder: 'TheBigBlueberry' },
    'thebox': { title: 'The Box', folder: 'TheBox' },
    'thecaseofthemissingbanana': { title: 'The Case Of The Missing Banana', folder: 'TheCaseOfTheMissingBanana' },
    'theeloquentpenguin': { title: 'The Eloquent Penguin', folder: 'TheEloquentPenguin' },
    'theexpert': { title: 'The Expert', folder: 'TheExpert' },
    'thehaircut': { title: 'The Haircut', folder: 'TheHaircut' },
    'theimpossibledoor': { title: 'The Impossible Door', folder: 'TheImpossibleDoor' },
    'themove': { title: 'The Move', folder: 'TheMove' },
    'theniblit': { title: 'The Niblit', folder: 'TheNiblit' },
    'theonlyexplanation': { title: 'The Only Explanation', folder: 'TheOnlyExplanation' },
    'thestoppedclock': { title: 'The Stopped Clock', folder: 'TheStoppedClock' },
    'thetreasuremap': { title: 'The Treasure Map', folder: 'TheTreasureMap' },
    'theunhappyraincloud': { title: 'The Unhappy Rain Cloud', folder: 'TheUnhappyRainCloud' },
    'weneedtotalkaboutthesandwich': { title: 'We Need To Talk About The Sandwich', folder: 'WeNeedToTalkAboutTheSandwich' },
    'wreakcoons': { title: 'Wreakcoons', folder: 'Wreakcoons' }
};

// Function to generate page URL with automatic extension detection
function generatePageUrl(bookId, pageNumber) {
    const book = bookMetadata[bookId.toLowerCase()];
    if (!book) return null;
    
    const paddedPageNumber = pageNumber.toString().padStart(3, '0');
    const baseFileName = `${book.folder}_${paddedPageNumber}`;
    
    // Return the first extension - the image loading will handle fallbacks
    return `${S3_BASE_URL}/${book.folder}/${baseFileName}.jpg`;
}

// Function to get book data with dynamic page generation
function getBookData(bookId) {
    const book = bookMetadata[bookId.toLowerCase()];
    if (!book) return null;
    
    return {
        title: book.title,
        folder: book.folder,
        // We'll generate pages dynamically as needed
        generatePageUrl: (pageNumber) => generatePageUrl(bookId, pageNumber)
    };
}

// Function to get page URL with extension fallback
function getPageUrl(bookId, pageIndex) {
    const book = getBookData(bookId);
    if (!book) return null;
    
    return book.generatePageUrl(pageIndex);
}
