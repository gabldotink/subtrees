# Discord

## [Discord Events](https://discord.js.org/#/docs/discord.js/stable/class/Client)

### Concept

Every [Discord Events](https://discord.js.org/#/docs/discord.js/stable/class/Client) would need to be concatenated in blocks while keeping their respective concept logic

### Block

When

*
  * [ ] Guild
  *
  [ ]   * [ ] Create _(_[_guildCreate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildCreate)_)_
  *
  [ ]   * [ ] Update _(_[_guildUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-guildUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_guildDelete_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildDelete)_)_
  *
  [ ]   * [ ] Unavailable _(_[_guildUnavailable_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-guildUnavailable)_)_
*
  * [ ] Member
  *
  [ ]   * [ ] Join _(_[_guildMemberAdd_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildMemberAdd)_)_
  *
  [ ]   * [ ] Update _(_[_guildMemberUpdate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildMemberUpdate)_)_
  *
  [ ]   * [ ] Presence Update _(_[_presenceUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-presenceUpdate)_)_
  *
  [ ]   * [ ] Leave _(_[_guildMemberRemove_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildMemberRemove)_)_
  *
  [ ]   * [ ] Ban _(_[_guildBanAdd_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildBanAdd)_)_
  *
  [ ]   * [ ] Unban _(_[_guildBanRemove_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildBanRemove)_)_
  *
  [ ]   * [ ] Available _(_[_guildMemberAvailable_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildMemberAvailable)_)_
  *
  [ ]   * [ ] Chunk _(_[_guildMembersChunk_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-guildMembersChunk)_)_
*
  * [ ] User
  *
  [ ]   * [ ] Update _(_[_userUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-userUpdate)_)_
  *
  [ ]   * [ ] Voice State Update _(_[_voiceStateUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-voiceStateUpdate)_)_
*
  * [ ] Channel
  *
  [ ]   * [ ] Create _(_[_channelCreate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-channelCreate)_)_
  *
  [ ]   * [ ] Update _(_[_channelUpdate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-channelUpdate)_)_
  *
  [ ]   * [ ] Pins Update _(_[_channelPinsUpdate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-channelPinsUpdate)_)_
  *
  [ ]   * [ ] Webhook Update _(_[_webhookUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-webhookUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_channelDelete_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-channelDelete)_)_
*
  * [ ] Thread
  *
  [ ]   * [ ] Create _(_[_threadCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadCreate)_)_
  *
  [ ]   * [ ] Update _(_[_threadUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadUpdate)_)_
  *
  [ ]   * [ ] Members Update _(_[_threadMembersUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadMembersUpdate)_)_
  *
  [ ]   * [ ] Member Update _(_[_threadMemberUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadMemberUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_threadDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadDelete)_)_
  *
  [ ]   * [ ] List Sync _(_[_threadListSync_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-threadListSync)_)_
*
  * [ ] Role
  *
  [ ]   * [ ] Create _(_[_roleCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-roleCreate)_)_
  *
  [ ]   * [ ] Update _(_[_roleUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-roleUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_roleDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-roleDelete)_)_
*
  * [ ] Message
  *
  [ ]   * [ ] Post _(_[_messageCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageCreate)_)_
  *
  [ ]   * [ ] Update _(_[_messageUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_messageDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageDelete)_)_
  *
  [ ]   * [ ] Bulk Delete _(_[_messageDeleteBulk_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageDeleteBulk)_)_
*
  * [ ] Reaction
  *
  [ ]   * [ ] Add _(_[_messageReactionAdd_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageReactionAdd)_)_
  *
  [ ]   * [ ] Remove _(_[_messageReactionRemove_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageReactionRemove)_)_
  *
  [ ]   * [ ] Remove Emoji _(_[_messageReactionRemoveEmoji_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageReactionRemoveEmoji)_)_
  *
  [ ]   * [ ] Remove All _(_[_messageReactionRemoveAll_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-messageReactionRemoveAll)_)_
*
  * [ ] Typing
  *
  [ ]   * [ ] Start _(_[_typingStart_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-typingStart)_)_
*
  * [ ] Invite
  *
  [ ]   * [ ] Create _(_[_inviteCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-inviteCreate)_)_
  *
  [ ]   * [ ] Delete _(_[_inviteDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-inviteDelete)_)_
*
  * [ ] Emoji
  *
  [ ]   * [ ] Create _(_[_emojiCreate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-emojiCreate)_)_
  *
  [ ]   * [ ] Update _(_[_emojiUpdate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-emojiUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_emojiDelete_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-emojiDelete)_)_
*
  * [ ] Sticker
  *
  [ ]   * [ ] Create _(_[_stickerCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stickerCreate)_)_
  *
  [ ]   * [ ] Update _(_[_stickerUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stickerUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_stickerDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stickerDelete)_)_
*
  * [ ] Scheduled Event
  *
  [ ]   * [ ] Create _(_[_guildScheduledEventCreate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildScheduledEventCreate)_)_
  *
  [ ]   * [ ] Update _(_[_guildScheduledEventUpdate_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildScheduledEventUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_guildScheduledEventDelete_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildScheduledEventDelete)_)_
  *
  [ ]   * [ ] Member Subscribe _(_[_guildScheduledEventUserAdd_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildScheduledEventUserAdd)_)_
  *
  [ ]   * [ ] Member Unsubscribe _(_[_guildScheduledEventUserRemove_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-guildScheduledEventUserRemove)_)_
*
  * [ ] Stage
  *
  [ ]   * [ ] Create _(_[_stageInstanceCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stageInstanceCreate)_)_
  *
  [ ]   * [ ] Update _(_[_stageInstanceUpdate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stageInstanceUpdate)_)_
  *
  [ ]   * [ ] Delete _(_[_stageInstanceDelete_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-stageInstanceDelete)_)_
*
  * [ ] Interaction
  *
  [ ]   * [ ] Request _(_[_interactionCreate_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-interactionCreate)_)_
*
  * [ ] API
  *
  [ ]   * [ ] Request _(_[_apiRequest_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-apiRequest)_)_
  *
  [ ]   * [ ] Response _(_[_apiResponse_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-apiResponse)_)_
*
  * [ ] Client
  *
  [ ]   * [ ] Ready _(_[_ready_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-ready)_)_
  *
  [ ]   * [ ] Debug _(_[_debug_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-debug)_)_
  *
  [ ]   * [ ] Warn _(_[_warn_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-warn)_)_
  *
  [ ]   * [ ] Error _(_[_error_](https://discord.js.org/#/docs/discord.js/stable/class/Client?scrollTo=e-error)_)_
  *
  [ ]   * [ ] Invalid Request Warning _(_[_invalidRequestWarning_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-invalidRequestWarning)_)_
  *
  [ ]   * [ ] Rate Limit _(_[_rateLimit_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-rateLimit)_)_
  *
  [ ]   * [ ] Invalidated _(_[_invalidated_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-invalidated)_)_
*
  * [ ] Shard
  *
  [ ]   * [ ] Ready _(_[_shardReady_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-shardReady)_)_
  *
  [ ]   * [ ] Resume _(_[_shardResume_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-shardResume)_)_
  *
  [ ]   * [ ] Disconnect _(_[_shardDisconnect_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-shardDisconnect)_)_
  *
  [ ]   * [ ] Reconnecting _(_[_shardReconnecting_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-shardReconnecting)_)_
  *
  [ ]   * [ ] Error _(_[_shardError_](https://discord.js.org/#/docs/main/stable/class/Client?scrollTo=e-shardError)_)_

### Links

* [Discord.js Events Documentation](https://discord.js.org/#/docs/discord.js/stable/class/Client)
* [Discord.js Documentation](https://discord.js.org/#/docs)
* [JavaScript Documentation](https://devdocs.io/javascript)
* [Node.js Documentation](https://devdocs.io/node/)
