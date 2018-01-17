//
//  Strings.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import Foundation

struct Intro {
	static let pageTitle = [Intro.firstTitle, Intro.secondTitle, Intro.thirdTitle]
	static let pageDescriptions = [Intro.firstText, Intro.secondText, Intro.thirdText]
	static let firstText = "کمک یار بحران زلزله"
	static let secondText = "آشنایان را از نگرانی در بیارید"
	static let thirdText = "سلامت یا جراحت بعد از وقوع زلزله"
	static let firstTitle = "انسان"
	static let secondTitle = "با یک دکمه"
	static let thirdTitle = "ارسال رایگان سیگنال"
}

struct UserDefaultTag {
	static let hasSeenIntro = "hasSeenIntro"
	static let guardiansCount = "guardiansCount"
	static let guardinas = "guardians"
	static let username = "username"
	static let mobile = "mobile"
	static let hasSent = "hasSent"
	static let notificationScheduled = "notificationScheduled"
	static let uuids = "uuids"
	static let token = "token"
	static let auth = "auth"
	static let hasTappedNotificationPermission = "hasTappedNotificationPermission"
	static let isUser = "isUser"
	static let userId = "userId"
	static let notificationId = "notificationId"
	static let version = "appVersion"
}

struct MainStrings {
	static let dangerFriendListHint = "کسی از شما با خبر نخواهد شد"
	static let addTwoMore = "برای اطمینان خاطر حداقل ۲ نفر دیگر را اضافه کنید"
	static let addOneMore = "برای اطمینان خاطر حداقل 1 نفر دیگر را اضافه کنید"
	static let threeAdded = "شما ۳ نفر افزوده اید"
	static let addGuardianText = "سلام لطفا برنامه << انسان >> رو دانلود کن. من شما رو به عنوان سرپرست خودم معرفی کردم تا در صورت زمین لرزه یا بروز حادثه از سلامت خودم با خبرتون کنم."
	static let appLink = "http://ensanapp.ir"
	static let guardianAlreadyAdded = "این شماره قبلا اضافه شده"
	static let error = "خطا!"
	static let notSent = "پیام ارسال نشد، کسی از شما با خبر نخواهد شد!"
	static let addMoreGuardian = "افزودن سرپرست"
	static let notifiedFine = "نفر از سلامت شما مطلع شدند"
	static let notifiedHurt = "نفر از حادثه شما مطلع شدند"
	static let success = "موفق"
	static let invitationSent = "پیام دعوت ارسال شد"
	static let localNotificationAlert = "شما سرپرستی ندارید و در خطر هستید، سرپرست جدید اضافه کنید."
	static let ok = "باشه"
}

struct ValidationErrors {
	static let fieldRequired = ""
	static let nameRequired = "نام کامل را وارد کنید"
	static let mobileRequired = "شماره موبایل را وارد کنید"
	static let incorrectMobileFormat = "شماره موبایل معتبر وارد کنید"
	static let incorrectNameFormat = "نام کامل را وارد کنید"
	static let sendAlertHint = "برای تمام سرپرستان شما هشدار جدی فرستاده میشود، آیا اطمینان دارید؟"
	static let alert = "توجه!"
}
