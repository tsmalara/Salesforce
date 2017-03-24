public class Utils_Testing {
    public static User createTestUser (String profileName) {
        Id profileId = ECO_Utils_Meta.getProfileId(profileName);
        
        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        Integer randomNumber2 = Integer.valueOf(Math.random()*1000);
        
        User u = new User();
        u.FirstName = randomNumber + 'tuser';
        u.LastName = randomNumber + 'tuser';
        u.Email = randomNumber + 'tuser' + '.' +randomNumber2 + 'tuser_consultant' + '@asdf.co';
        u.Username =  randomNumber + 'tuser' + '.' +randomNumber2 + 'tuser' + '@asdf.co' + '.test';
        u.CommunityNickname = randomNumber + '' + randomNumber2 + 'tuser';
        u.Alias = randomNumber + '' + randomNumber2;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = profileId;
        u.LanguageLocaleKey = 'en_US';
        return u;
    }
    
}