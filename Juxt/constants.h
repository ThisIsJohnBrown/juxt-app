// #define baseURL @"http://juxt-dev.clxvi.webfactional.com"

#if TARGET_IPHONE_SIMULATOR
#define baseURL @"http://juxt.local:7400"
#else
#define baseURL @"http://juxt-dev.clxvi.webfactional.com"
#endif

#define identLength 4