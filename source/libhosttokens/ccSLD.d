/**
* Copyright:
* (C) 2016 Martin Brzenska
*
* License:
* Distributed under the terms of the MIT license.
* Consult the provided LICENSE.md file for details
*/
module libhosttokens.ccSLD;

immutable string[][string] ccSLDs;
static this() {

	/**
	* see: http://www.quackit.com/domain-names/country_domain_extensions.cfm
	*/
	ccSLDs = [
		"au":[
			"asn",
			"com",
			"net",
			"id",
			"org",
			"edu",
			"gov",
			"csiro",
			"act",
			"nsw",
			"nt",
			"qld",
			"sa",
			"tas",
			"vic",
			"wa"
			],
		"at":[
			"co",
			"or",
			"priv",
			"ac"
		],
		"fr":[
			"avocat",
			"aeroport",
			"veterinaire"
		],
		"hu":[
			"co",
			"film",
			"lakas",
			"ingatlan",
			"sport",
			"hotel"
		],
		"nz":[
			"ac",
			"co",
			"geek",
			"gen",
			"kiwi",
			"maori",
			"net",
			"org",
			"school",
			"cri",
			"govt",
			"health",
			"iwi",
			"mil",
			"parliament"
		],
		"li":[
			"ac",
			"co",
			"org",
			"net",
			"k12",
			"gov",
			"muni",
			"idf"
		],
		//todo: ru
		//todo: kr
		"za":[
			"ac",
			"gov",
			"law",
			"mil",
			"nom",
			"school",
			"net"
		],
		"uk":[
			"co",
			"org",
			"me",
			"ltd",
			"plc",
			"net",
			"sch",
			"ac",
			"gov",
			"mod",
			"mil",
			"nhs",
			"police"
		]
	];
}
