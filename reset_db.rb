UserKeywordHit.delete_all
UserKeyword.delete_all
UserSnippet.delete_all

k = UserAuthentication.first

k.last_position = nil
k.save!
