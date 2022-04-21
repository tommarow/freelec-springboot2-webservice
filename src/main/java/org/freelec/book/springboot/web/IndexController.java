package org.freelec.book.springboot.web;

import lombok.RequiredArgsConstructor;
import org.freelec.book.springboot.config.auth.LoginUser;
import org.freelec.book.springboot.config.auth.dto.SessionUser;
import org.freelec.book.springboot.service.posts.PostsService;
import org.freelec.book.springboot.web.dto.PostsResponseDto;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import javax.servlet.http.HttpSession;

@RequiredArgsConstructor
@Controller
public class IndexController {

    private final PostsService postsService;
//    private final HttpSession httpSession; // @LoginUser 추가 후 삭제 부분

    @GetMapping("/")
    public String index(Model model, @LoginUser SessionUser user) {
        model.addAttribute("posts", postsService.findAllDesc());
        // 앞서 작성된 CustomOAuth2UserService에서 로그인 성공 시 세션에 SessionUser를 저장하도록 구성
        // 즉, 로그인 성공시 httpSession.getAttribute("user")에서 값을 가져올 수 있다.
//        SessionUser user = (SessionUser) httpSession.getAttribute("user"); // @LoginUser 추가 후 삭제 부분

        if (user != null) {
            // 세션에 저장된 값이 있을 때만 model에 userName으로 등록.
            // 세션에 저장된 값이 없으면 model엔 아무런 값이 없는 상태로 로그인 버튼이 출력됨.
            model.addAttribute("userName", user.getName());
        }
        return "index";
    }

    @GetMapping("/posts/save")
    public String postsSave() {
        return "posts-save";
    }

    @GetMapping("/posts/update/{id}")
    public String postsUpdate(@PathVariable Long id, Model model) {
        PostsResponseDto postsResponseDto = postsService.findById(id);
        model.addAttribute("post", postsResponseDto);

        return "posts-update";
    }
}
