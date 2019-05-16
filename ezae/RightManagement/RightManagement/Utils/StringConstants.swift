//
//  StringConstants.swift
//  right
//
//  Created by Baljeet Gaheer on 13/11/17.
//  Copyright © 2017 Baljeet Gaheer. All rights reserved.
//

import Foundation
struct StringConstants {
    static let SINGLE_TYPE_QUESTION = "single"
    static let MULTI_TYPE_QUESTION = "multi"
    static let LONG_TYPE_QUESTION = "longQuestion"
    static let YES_NO_TYPE_QUESTION = "yesNo"
    static let MEDIA_TYPE_QUESTION = "media"
    static let DOC_TYPE_QUESTION = "doc"
    static let LIKART_SCALE_TYPE_QUESTION = "likartScale"
    static let ESTIMATE_PERCENT_TYPE_QUESTION = "estimatePercentage"
    static let SEQUENCING = "sequencing"
    static let WEB_PAGE_TYPE_QUESTION = "web_page"
    static var ACTION_API_URL = "http://www.ezae.in/Actions/Mobile/"
    static let WEB_API_URL = "http://www.ezae.in/"
    static let IMAGE_URL = "http://www.ezae.in/images/"
    static let USER_IMAGE_URL = "http://www.ezae.in/images/UserImages/"
    static let DOC_URL = WEB_API_URL + "docs/moduledocs/";
    static let LESSION_TYPE_MODULE = "lesson"
    static let SUBMITTED_SUCCESSFULLY = "Submitted Successfully"
    static let NOMINATE_TRAINING_CONFIRM = "Are you sure you want to nominate this training?"
    //User Actions
    static let LOGIN_URL = ACTION_API_URL + "UserAction.php?call=login&username={0}&password={1}&deviceid={2}"
    static let GET_DASHBOARD_COUNTS = ACTION_API_URL+"UserAction.php?call=getDashboardStats&userSeq={0}&companySeq={1}";
    static let GET_COUNTS = ACTION_API_URL+"UserAction.php?call=getDashboardCounts&userSeq={0}&companySeq={1}";
    static let GET_NOTIFICATION = ACTION_API_URL+"UserAction.php?call=getNotifications&userSeq={0}&companySeq={1}";
    static let GET_NOTIFICATIONS_NEW = ACTION_API_URL + "NotificationAction.php?call=getAllNotifications&userSeq={0}&companySeq={1}";
    static let CHANGE_PASSWORD = ACTION_API_URL + "UserAction.php?call=changePassword&userSeq={0}&companySeq={1}&earlierPassword={2}&newPassword={3}"
    static let NOMINATE_TRAINING = ACTION_API_URL+"UserAction.php?call=nominateCT&userSeq={0}&companySeq={1}&trainingSeq={2}&lpSeq={3}"
    static let GET_NOTES = ACTION_API_URL + "NoteAction.php?call=getAllNotes&userSeq={0}&companySeq={1}"
    static let GET_NOTE_DETAIL = ACTION_API_URL + "NoteAction.php?call=getNoteDetails&userSeq={0}&companySeq={1}&noteSeq={2}"
    static let GET_ACHIEVEMENTS = ACTION_API_URL + "UserAction.php?call=myAchievements&userSeq={0}&companyseq={1}"
    static let SAVE_NOTES = ACTION_API_URL + "NoteAction.php?call=saveNote&userSeq={0}&companySeq={1}&seq={2}&details={3}"
    static let DELETE_NOTES = ACTION_API_URL + "NoteAction.php?call=deleteNote&userSeq={0}&companySeq={1}&noteSeq={2}"
    static let GET_LEADERBOARD_BY_MODULE = ACTION_API_URL + "UserAction.php?call=getLeaderBoardDataByModule&userSeq={0}&companySeq={1}&moduleSeq={2}";
    static let GET_LEADERBOARD_BY_PROFILE = ACTION_API_URL + "UserAction.php?call=getLeaderBoardDataByProfile&userSeq={0}&companySeq={1}&profileSeq={2}";
    static let GET_LEADERBOARD_BY_LEARNINGPLAN = ACTION_API_URL + "UserAction.php?call=getLeaderBoardDataByLearningPlan&userSeq={0}&companySeq={1}&lpSeq={2}";
    static let GET_SCORES = ACTION_API_URL + "UserAction.php?call=getScoresByLearningPlan&userSeq={0}&companySeq={1}&lpSeq={2}";
    

    static let SYNCH_USERS = ACTION_API_URL + "UserAction.php?call=synchUsersAndAdmins&userSeq={0}&companySeq={1}"

    static let GET_USER_DETAIL = ACTION_API_URL + "UserAction.php?call=getUserDetail&userSeq={0}&companySeq={1}";
    static let UPDATE_USER_PROFILE = ACTION_API_URL + "UserAction.php?call=updateUserProfile&userSeq={0}&companySeq={1}&userProfileDetail={2}";
    static let GET_PROFILE_AND_MODULES = ACTION_API_URL + "UserAction.php?call=getProfilesAndModules&userSeq={0}&companySeq={1}";
    
    //Learning Plan Actions
    static let GET_LEARNING_PLAN = ACTION_API_URL + "LearningPlanAction.php?call=getLearningPlans&userSeq={0}&companySeq={1}"
    static let GET_LEARNING_PLAN_DETAIL = ACTION_API_URL + "LearningPlanAction.php?userSeq={0}&companySeq={1}&call=getLearningPlanDetails"
    static let GET_LEARNING_PLAN_MODULES = ACTION_API_URL + "LearningPlanAction.php?userSeq={0}&companySeq={1}&learningPlanSeq={2}&call=getLearningPlanModules"
    static let GET_ALL_LEARNING_PLANS = ACTION_API_URL + "LearningPlanAction.php?userSeq={0}&companySeq={1}&call=getLearningPlansByUser"
    
    //Badge Actions
    static let GET_ACHIEVEMENT_BADGES = ACTION_API_URL + "BadgeAction.php?call=myAchievementMyBadges&userSeq={0}&companyseq={1}"
    
    //Message Actions
    static let GET_MESSSAGES = ACTION_API_URL + "MessageAction.php?call=getMessages&userSeq={0}&companySeq={1}"
    
    static let MESSAGE_MARK_AS_READ = ACTION_API_URL + "MessageAction.php?call=markReadAndUnRead&userSeq={0}&companySeq={1}&chattingWithUserSeq={2}&chattingWithUserType={3}&isRead={4}"
  
    static let GET_MESSAGE_DETAIL = ACTION_API_URL + "MessageAction.php?call=getMessageDetails&userSeq={0}&companySeq={1}&chattingWithUserSeq={2}&chattingWithUserType={3}&afterMessageSeq={4}"
    static let SEND_MESSAGE = ACTION_API_URL + "MessageAction.php?call=sendMessageChat&userSeq={0}&companySeq={1}&chattingWithUserSeq={2}&chattingWithUserType={3}&message={4}&chatLoadedTillSeq={5}"
    
    //Module Actions
    static let GET_MODULES = ACTION_API_URL + "ModuleAction.php?&call=getDirectModules&userSeq={0}&companySeq={1}"
    static let GET_MODULE_DETAIL = ACTION_API_URL + "ModuleAction.php?call=getModuleDetails&userSeq={0}&moduleSeq={1}&learningPlanSeq={2}&isreattempted={3}"
    
    static let SUBMIT_MODULE_PROGRESS = ACTION_API_URL  + "QuizProgressAction.php?call=saveQuizProgress&userSeq={0}&companySeq={1}&answers={2}"
    
    //ActivityAction
    static let SAVE_ACTIVITY = ACTION_API_URL + "ActivityAction.php?call=saveActivity&userSeq={0}&companySeq={1}&activityData={2}"
    
    
    
    
    //Action Names
    static let DASHBOARD_DATA_ACTION = "getDashboardData"
    static let NOTIFICATION_ACTION = "getNotifications"
    static let LEARNING_PLAN_ACTION = "getLearningPlans"
    
    //Chat Action
    static let GET_CHATROOMS = ACTION_API_URL + "ChatroomAction.php?call=getChatrooms&userSeq={0}&companySeq={1}"
    static let GET_CHATROOM_DETAIL = ACTION_API_URL + "ChatroomAction.php?call=getChatroomDetails&userSeq={0}&companySeq={1}&chatroomId={2}&afterMessageSeq={3}"
    static let SEND_CHAT_MESSAGE = ACTION_API_URL + "ChatroomAction.php?call=sendMessageChat&userSeq={0}&companySeq={1}&chatroomId={2}&userType={3}&userName={4}&afterMessageSeq={5}&message={6}"
    static let GET_EVENTS = ACTION_API_URL + "ChatroomAction.php?call=getAllEvents&userSeq={0}&companySeq={1}"
    
    //Notification Action
    static let MARK_AS_READ_NOTIFICATION = ACTION_API_URL + "NotificationAction.php?call=markReadOrUnRead&isRead=1&userSeq={0}&companySeq={1}";
    static let DELETE_NOTIFICATION = ACTION_API_URL + "NotificationAction.php?call=markAsClearNotification&userSeq={0}&companySeq={1}&seq={2}";
   
    
}
