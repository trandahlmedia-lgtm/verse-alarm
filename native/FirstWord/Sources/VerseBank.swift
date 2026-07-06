import Foundation

struct Verse: Identifiable, Equatable {
    let ref: String
    let text: String
    var id: String { ref }
}

/// World English Bible (public domain) — same 36-verse bank as the web app,
/// rotated by day-of-year so everyone gets the same verse on the same day.
enum VerseBank {
    static func today(_ date: Date = Date()) -> Verse {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return all[day % all.count]
    }

    static func random() -> Verse {
        all.randomElement() ?? all[0]
    }

    static let all: [Verse] = [
        Verse(ref: "Psalm 118:24", text: "This is the day that the Lord has made. We will rejoice and be glad in it."),
        Verse(ref: "Lamentations 3:22–23", text: "It is because of the Lord's loving kindnesses that we are not consumed, because his mercies do not fail. They are new every morning. Great is your faithfulness."),
        Verse(ref: "Philippians 4:13", text: "I can do all things through Christ who strengthens me."),
        Verse(ref: "Joshua 1:9", text: "Be strong and courageous. Do not be afraid. Do not be dismayed, for the Lord your God is with you wherever you go."),
        Verse(ref: "Proverbs 3:5–6", text: "Trust in the Lord with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make your paths straight."),
        Verse(ref: "Isaiah 40:31", text: "Those who wait for the Lord will renew their strength. They will mount up with wings like eagles. They will run, and not be weary. They will walk, and not faint."),
        Verse(ref: "Psalm 23:1", text: "The Lord is my shepherd. I shall lack nothing."),
        Verse(ref: "Matthew 6:33", text: "Seek first God's Kingdom and his righteousness, and all these things will be given to you as well."),
        Verse(ref: "Romans 8:28", text: "We know that all things work together for good for those who love God, for those who are called according to his purpose."),
        Verse(ref: "Psalm 46:10", text: "Be still, and know that I am God. I will be exalted among the nations. I will be exalted in the earth."),
        Verse(ref: "Ephesians 2:8–9", text: "For by grace you have been saved through faith, and that not of yourselves. It is the gift of God, not of works, that no one would boast."),
        Verse(ref: "Psalm 121:1–2", text: "I will lift up my eyes to the hills. Where does my help come from? My help comes from the Lord, who made heaven and earth."),
        Verse(ref: "John 8:12", text: "I am the light of the world. He who follows me will not walk in the darkness, but will have the light of life."),
        Verse(ref: "Galatians 6:9", text: "Let us not be weary in doing good, for we will reap in due season if we do not give up."),
        Verse(ref: "Psalm 34:8", text: "Oh taste and see that the Lord is good. Blessed is the man who takes refuge in him."),
        Verse(ref: "Matthew 11:28", text: "Come to me, all you who labor and are heavily burdened, and I will give you rest."),
        Verse(ref: "2 Timothy 1:7", text: "For God did not give us a spirit of fear, but of power, love, and self-control."),
        Verse(ref: "Psalm 90:14", text: "Satisfy us in the morning with your loving kindness, that we may rejoice and be glad all our days."),
        Verse(ref: "James 1:5", text: "If any of you lacks wisdom, let him ask of God, who gives to all liberally and without reproach, and it will be given to him."),
        Verse(ref: "Isaiah 41:10", text: "Do not be afraid, for I am with you. Do not be dismayed, for I am your God. I will strengthen you. Yes, I will help you."),
        Verse(ref: "Psalm 27:1", text: "The Lord is my light and my salvation. Whom shall I fear? The Lord is the strength of my life. Of whom shall I be afraid?"),
        Verse(ref: "Colossians 3:23", text: "Whatever you do, work heartily, as for the Lord and not for men."),
        Verse(ref: "Proverbs 16:3", text: "Commit your deeds to the Lord, and your plans shall succeed."),
        Verse(ref: "Psalm 143:8", text: "Cause me to hear your loving kindness in the morning, for I trust in you. Cause me to know the way in which I should walk, for I lift up my soul to you."),
        Verse(ref: "Romans 12:2", text: "Do not be conformed to this world, but be transformed by the renewing of your mind, so that you may prove what is the good, well-pleasing, and perfect will of God."),
        Verse(ref: "1 Corinthians 16:13", text: "Watch. Stand firm in the faith. Be courageous. Be strong. Let all that you do be done in love."),
        Verse(ref: "Psalm 5:3", text: "Lord, in the morning you will hear my voice. In the morning I will lay my requests before you, and will watch expectantly."),
        Verse(ref: "Micah 6:8", text: "He has shown you, O man, what is good. What does the Lord require of you, but to act justly, to love mercy, and to walk humbly with your God?"),
        Verse(ref: "John 16:33", text: "In the world you have trouble, but cheer up. I have overcome the world."),
        Verse(ref: "Psalm 37:4", text: "Also delight yourself in the Lord, and he will give you the desires of your heart."),
        Verse(ref: "Hebrews 12:1", text: "Let us also lay aside every weight and the sin which so easily entangles us, and let us run with perseverance the race that is set before us."),
        Verse(ref: "Zephaniah 3:17", text: "The Lord your God is among you, a mighty one who will save. He will rejoice over you with joy. He will rest in his love."),
        Verse(ref: "Psalm 19:14", text: "Let the words of my mouth and the meditation of my heart be acceptable in your sight, O Lord, my rock and my redeemer."),
        Verse(ref: "Matthew 5:16", text: "Let your light shine before men, that they may see your good works and glorify your Father who is in heaven."),
        Verse(ref: "1 Thessalonians 5:16–18", text: "Always rejoice. Pray without ceasing. In everything give thanks, for this is the will of God in Christ Jesus toward you."),
        Verse(ref: "Psalm 16:8", text: "I have set the Lord always before me. Because he is at my right hand, I shall not be moved.")
    ]
}
