Server patch guidance

1) Fix routing for /api/chat/send
- Ensure you have a controller under a package scanned by Spring Boot (same root package).
- Example minimal controller:

```java
@RestController
@RequestMapping("/api/chat")
public class ChatController {
  private final AiService aiService;

  public ChatController(AiService aiService) { this.aiService = aiService; }

  @PostMapping("/send")
  public ResponseEntity<?> send(@RequestBody Map<String,String> body, Principal principal) {
    String message = body.get("message");
    // Use principal or SecurityContext to find user
    String reply = aiService.reply(message, principal);
    return ResponseEntity.ok(Collections.singletonMap("reply", reply));
  }
}
```

2) Avoid greedy static resource handlers
- In WebMvcConfigurer, do not map "**" to static resources. Keep a narrow mapping like "/static/**" or ensure controllers are checked first.

3) Ensure JWT -> user mapping
- Your authentication filter should decode JWT and set Authentication in SecurityContextHolder.
- In controller or service that creates journal entries, use the authenticated user id (e.g., via `@AuthenticationPrincipal` or SecurityContext) to set `user_id` on inserts.

4) Logging to diagnose
- Add request path and headers logging for incoming requests to see why /api/chat/send is reaching static handler.
- Example: add a OncePerRequestFilter that logs servlet path and whether a controller mapping was found.

If you want, provide the backend repository or the controller and resource config files and I will craft exact patch files.
