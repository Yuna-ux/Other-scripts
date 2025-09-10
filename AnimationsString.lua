function getGitHubRawUrl(user, repo, branch, filePath)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s",
        user, repo, branch, filePath)
end

local url = getGitHubRawUrl("Yuna-ux", "Other-scripts", "main", "AnimationsTable.lua")

return loadstring(game:HttpGet(url))
