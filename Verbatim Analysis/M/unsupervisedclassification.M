let   
    content_type = "application/json", 
    post_data = (verbatim as text, max_tokens as number, temperature as number) =>  
        let 
            temperatureTXT = Replacer.ReplaceText(Text.From(temperature), ",", "."), //Temperature must be written with a dot a decimal separator
            // prompt coming from an Excel cell
            systemMessage = Classification_prompt ,
            // no carriage return in the global prompt
            json = "{""messages"" : [
                        {""role"":""system"",""content"":""" & systemMessage & """},
                        {""role"":""user"",""content"":""" & Replacer.ReplaceText(Replacer.ReplaceText(verbatim, "#(lf)", " "), """", "'") & """}
                        ]
                    , ""max_tokens"":" & Text.From(max_tokens) & ", ""temperature"":" & temperatureTXT & 
                    "}",
            post_request = Web.Contents(  
                "https://" & api_base & ".openai.azure.com/openai/deployments/" & deployment & "/chat/completions?api-version=" & api_version & "&Content-Type=" & content_type & "&api-key=" & api_key,  
                [  
                    Headers = [#"Content-Type"=content_type],  
                    Content = Text.ToBinary(json),  
                    ManualStatusHandling={400..499, 500..599}  
                ]  
            ),  
            response = if (Value.Metadata(post_request)[Response.Status] = 200) then Json.Document(post_request) else null
            // AI assistant's message is hidden in the JSON result
            , choices = response[choices]
            , choice = choices{0}
            , message = choice[message]
            , content = message[content]
        in content
in  post_data
